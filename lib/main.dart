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

import 'package:flutter/material.dart';
import 'screens/blind_feed_screen.dart';
import 'screens/found_item_form_screen.dart'; // Import the new form
//import 'screens/login_screen.dart';           // Import login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniFound',
      theme: ThemeData.dark(),
      // 1. Define the starting page
      initialRoute: '/', 
      
      // 2. The Route Table: This links the "Pathways" to the actual Screens
      routes: {
        //'/': (context) => const LoginScreen(),
        '/': (context) => const BlindFeedScreen(),
        '/found-form': (context) => const FoundItemFormScreen(),
      },
    );
  }
}
