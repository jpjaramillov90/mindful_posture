import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_navigation.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras Firebase conecta con Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si no hay usuario → login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Si hay usuario → cargar datos de Firestore
        return FutureBuilder<Map<String, dynamic>>(
          future: auth.getUserData(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Error cargando datos del usuario')),
              );
            }

            final userData = userSnapshot.data!;
            return MainNavigation(
              name: userData['name'] ?? '',
              lastName: userData['lastName'] ?? '',
            );
          },
        );
      },
    );
  }
}
