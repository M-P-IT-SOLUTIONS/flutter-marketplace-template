import 'package:flutter/material.dart';
import 'package:randki/main.dart';
import 'package:randki/screens/auth/welcome_screen.dart';
import 'package:randki/screens/main/navigation_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        // First launch - wait for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        // If there's a session -> HomePage, if not -> LoginPage
        if (session != null) {
          return NavigationScreen(); // e.g. main screen after login
        } else {
          return WelcomeScreen(); // e.g. login / registration screen
        }
      },
    );
  }
}
