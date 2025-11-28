import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final String name;
  final String lastName;

  const HomeScreen({super.key, required this.name, required this.lastName});

  String getInitials() {
    final firstInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar con iniciales
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  getInitials(),
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "¡Hola, $name $lastName!",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Bienvenido a MindfulPosture",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
