// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'screens/login_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Campus Lost & Found',
//       debugShowCheckedModeBanner: false,
//       home: const LoginScreen(),
//       theme: ThemeData(
//         useMaterial3: true,
//         scaffoldBackgroundColor: Colors.transparent,
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'screens/blind_feed_screen.dart';
// import 'screens/found_item_form_screen.dart'; // Import the new form
// import 'screens/login_screen.dart';
// import 'services/api_service.dart';
// import 'services/item_api_service.dart';
// import 'constants.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final api = ApiService();
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'UniFound',
//       theme: ThemeData.dark(),
//       // Start at login
//       initialRoute: '/login',
//       routes: {
//         '/login': (context) => const LoginScreen(),
//         '/home': (context) => BlindFeedScreen(
//               apiService: ItemApiService(baseUrl: baseUrl, getToken: api.getToken),
//               onLogout: () {
//                 // VoidCallback wrapper that runs async logout logic
//                 () async {
//                   try {
//                     final ok = await api.logout();
//                     if (ok) {
//                       await api.deleteToken();
//                       if (context.mounted) {
//                         Navigator.pushReplacementNamed(context, '/login');
//                       }
//                     } else {
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Logout failed'),
//                             backgroundColor: Colors.redAccent,
//                           ),
//                         );
//                       }
//                     }
//                   } catch (e) {
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(e.toString()),
//                           backgroundColor: Colors.redAccent,
//                         ),
//                       );
//                     }
//                   }
//                 }();
//               },
//             ),
//         '/found-form': (context) => const FoundItemFormScreen(),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'screens/blind_feed_screen.dart';
import 'screens/found_item_form_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/item_api_service.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We instantiate this here so it's available for the routes
    final api = ApiService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniFound',
      theme: ThemeData.dark(),
      
      // 1. CHANGE THIS TO '/home' to bypass login on startup
      initialRoute: '/home', 

      routes: {
        '/login': (context) => const LoginScreen(),
        
        '/home': (context) => BlindFeedScreen(
          apiService: ItemApiService(
            baseUrl: baseUrl, 
            getToken: api.getToken,
          ),
          onLogout: () async {
            try {
              // Hit the backend logout endpoint
              //final ok = await api.logout();
              
              // Even if the network call fails, we usually want to 
              // clear the local token to "force" a logout on the UI
              await api.deleteToken();

              if (context.mounted) {
                // 2. Navigate back to login and remove the home screen from history
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout Error: $e'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                // Still redirect to login if the session is dead
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            }
          },
        ),
        '/found-form': (context) => const FoundItemFormScreen(),
      },
    );
  }
}