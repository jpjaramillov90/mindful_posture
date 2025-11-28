import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RoutineTimer extends StatefulWidget {
  final String title;
  final String description;
  final int durationSeconds; // cambio: duración en segundos
  final VoidCallback? onComplete;

  const RoutineTimer({
    super.key,
    required this.title,
    required this.description,
    required this.durationSeconds,
    this.onComplete,
  });

  @override
  State<RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends State<RoutineTimer> {
  late int secondsRemaining;
  Timer? timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    secondsRemaining = widget.durationSeconds; // directamente en segundos
  }

  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          timer.cancel();
          isRunning = false;
          if (widget.onComplete != null) widget.onComplete!();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('¡Rutina completada!')));
        }
      });
    });
  }

  void pauseTimer() {
    timer?.cancel();
    isRunning = false;
  }

  void resetTimer() {
    pauseTimer();
    setState(() {
      secondsRemaining = widget.durationSeconds;
    });
  }

  String formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.description,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              formatTime(secondsRemaining),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: startTimer,
                  child: const Text(
                    'Iniciar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  onPressed: pauseTimer,
                  child: const Text(
                    'Pausar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: resetTimer,
                  child: const Text(
                    'Reiniciar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
