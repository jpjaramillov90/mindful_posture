import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'routines_screen.dart';
import 'sensors_screen.dart';
import 'logs_screen.dart';
import '../theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  final String name;
  final String lastName;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
    required this.name,
    required this.lastName,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void jumpTo(int index) {
    setState(() => currentIndex = index);
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // cancelar
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop(); // cerrar diálogo
            },
            child: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(name: widget.name, lastName: widget.lastName),
      RoutinesScreen(),
      SensorsScreen(),
      LogsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Hola, ${widget.name} ${widget.lastName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new),
            label: "Rutinas",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: "Sensores"),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historial",
          ),
        ],
      ),
    );
  }
}
