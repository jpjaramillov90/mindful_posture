import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoutineTimer extends StatefulWidget {
  final String title;
  final String description;
  final int durationSeconds;
  final String routineId;

  const RoutineTimer({
    super.key,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.routineId,
  });

  @override
  State<RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends State<RoutineTimer> {
  late int secondsRemaining;
  Timer? timer;
  bool isRunning = false;

  final FirestoreService firestore = FirestoreService();
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    secondsRemaining = widget.durationSeconds;
    _checkResetRoutines();
  }

  // --------------------
  // Temporizador
  // --------------------
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
          _markRoutineComplete();
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

  // --------------------
  // Marcar rutina como completada
  // --------------------
  Future<void> _markRoutineComplete() async {
    await firestore.updateRoutine(widget.routineId, {'completed': true});
  }

  // --------------------
  // Revisar y resetear rutinas cada 8h
  // --------------------
  Future<void> _checkResetRoutines() async {
    final lastReset = await firestore.getLastReset(user.uid);
    final now = DateTime.now();

    if (lastReset == null || now.difference(lastReset).inHours >= 8) {
      await firestore.resetAllRoutines(user.uid);
      await firestore.updateLastReset(user.uid, now);
    }
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
