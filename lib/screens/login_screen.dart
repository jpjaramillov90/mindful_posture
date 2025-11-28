import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  bool loading = false;
  String? errorMessage;
  bool obscurePassword = true; // Estado para mostrar/ocultar contraseña

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo
                Image.asset('assets/logo.png', width: 120, height: 120),
                const SizedBox(height: 20),

                // Nombre de la app
                const Text(
                  "MindfulPosture",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Campo correo
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Correo",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo contraseña con mostrar/ocultar
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Mensaje de error
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),

                // Botón Iniciar sesión centrado y ancho relativo
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => loading = true);

                      final error = await auth.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );

                      setState(() => loading = false);

                      if (error == null) {
                        // Login OK
                        Navigator.pop(context);
                      } else {
                        setState(() => errorMessage = error);
                      }
                    },
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Iniciar sesión"),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón Crear cuenta
                TextButton(
                  onPressed: () {
                    // Navegar a pantalla de registro
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text("Crear una cuenta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
