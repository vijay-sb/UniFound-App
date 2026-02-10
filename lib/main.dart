import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/blind_feed_screen.dart';
import 'screens/found_item_form_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/item_api_service.dart';
import 'constants.dart';

Future<void> main() async {
  await Supabase.initialize(
  url: 'https://vxjbrldfgvndzoraqmhf.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4amJybGRmZ3ZuZHpvcmFxbWhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NDE0NzksImV4cCI6MjA4NjIxNzQ3OX0.tPzSxlMTfGiF1kpMfWPScJgWXKkY3dhRjUJikPE-w88',
);

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
      initialRoute: '/login', 

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