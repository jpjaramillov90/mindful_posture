import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text("Login correcto ✔", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
