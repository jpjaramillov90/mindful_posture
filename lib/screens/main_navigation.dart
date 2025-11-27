import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'routines_screen.dart';
import 'sensors_screen.dart';
import 'logs_screen.dart';
import '../theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

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

  @override
  Widget build(BuildContext context) {
    // importantísimo: construir las pantallas aquí
    final screens = [
      HomeScreen(),
      RoutinesScreen(),
      SensorsScreen(),
      LogsScreen(),
    ];

    return Scaffold(
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
