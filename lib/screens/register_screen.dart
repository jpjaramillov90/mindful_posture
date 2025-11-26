import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  String? errorMessage;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Correo",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                setState(() => loading = true);
                final error = await auth.register(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
                setState(() => loading = false);

                if (error == null) {
                  Navigator.pop(context); // volver al login
                } else {
                  setState(() => errorMessage = error);
                }
              },
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Crear cuenta"),
            ),
          ],
        ),
      ),
    );
  }
}
