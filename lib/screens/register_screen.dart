import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? errorMessage;
  bool _obscurePassword = true; // <-- Para mostrar/ocultar contraseña

  Future<void> registerUser() async {
    setState(() => loading = true);
    try {
      // 1) Crear usuario en Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;

      // 2) Guardar datos extra en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': DateTime.now(),
      });

      // 3) Volver a pantalla anterior
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } catch (e) {
      setState(() => errorMessage = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Nombre
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Apellido
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Correo
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Contraseña con icono para mostrar/ocultar
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Mensaje de error
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Registrarme
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading ? null : registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Registrarme',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Cancelar
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
