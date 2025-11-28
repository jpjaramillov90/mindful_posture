import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import 'routine_timer.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final firestore = FirestoreService();
  final user = FirebaseAuth.instance.currentUser!;
  final Set<String> completedRoutines = {}; // Rutinas completadas

  String formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // CREAR NUEVA RUTINA
  Future<void> _addRoutine(BuildContext context) async {
    final nameController = TextEditingController();
    final durationController = TextEditingController();
    final instructionsController = TextEditingController();
    String selectedDifficulty = 'facil';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva rutina"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedDifficulty,
                decoration: const InputDecoration(labelText: "Dificultad"),
                items: const [
                  DropdownMenuItem(value: 'facil', child: Text('Fácil')),
                  DropdownMenuItem(value: 'media', child: Text('Media')),
                  DropdownMenuItem(value: 'dificil', child: Text('Difícil')),
                ],
                onChanged: (value) {
                  if (value != null) selectedDifficulty = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Duración (seg)"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(labelText: "Instrucciones"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              await firestore.addRoutine({
                'name': nameController.text.trim(),
                'difficulty': selectedDifficulty,
                'duration': int.tryParse(durationController.text) ?? 0,
                'instructions': instructionsController.text.trim(),
                'createdBy': user.uid,
                'timestamp': Timestamp.now(),
                'completed': false,
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Guardar",
              style: TextStyle(color: AppColors.background),
            ),
          ),
        ],
      ),
    );
  }

  // EDITAR RUTINA
  Future<void> _editRoutine(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final nameController = TextEditingController(text: data['name']);
    final durationController = TextEditingController(
      text: data['duration'].toString(),
    );
    final instructionsController = TextEditingController(
      text: data['instructions'],
    );
    String selectedDifficulty = data['difficulty'] ?? 'facil';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar rutina"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedDifficulty,
                decoration: const InputDecoration(labelText: "Dificultad"),
                items: const [
                  DropdownMenuItem(value: 'facil', child: Text('Fácil')),
                  DropdownMenuItem(value: 'media', child: Text('Media')),
                  DropdownMenuItem(value: 'dificil', child: Text('Difícil')),
                ],
                onChanged: (value) {
                  if (value != null) selectedDifficulty = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Duración (seg)"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(labelText: "Instrucciones"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              await firestore.updateRoutine(docId, {
                'name': nameController.text.trim(),
                'difficulty': selectedDifficulty,
                'duration': int.tryParse(durationController.text) ?? 0,
                'instructions': instructionsController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Guardar",
              style: TextStyle(color: AppColors.background),
            ),
          ),
        ],
      ),
    );
  }

  // ELIMINAR RUTINA
  Future<void> _deleteRoutine(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar rutina"),
        content: const Text("¿Seguro que quieres eliminar esta rutina?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: AppColors.background),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await firestore.deleteRoutine(docId);
      completedRoutines.remove(docId);
    }
  }

  // INICIAR RUTINA
  void _startRoutine(Map<String, dynamic> data, String docId) {
    final duration = data['duration'] ?? 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineTimer(
          title: data['name'] ?? '',
          description: data['instructions'] ?? '',
          durationSeconds: duration,
          routineId: docId, // obligatorio para marcar completada en Firestore
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rutinas y Pausas Activas")),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getRoutinesByUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Ocurrió un error al cargar las rutinas."),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No hay rutinas disponibles."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              final completed =
                  completedRoutines.contains(docId) ||
                  data['completed'] == true;

              return Card(
                color: completed ? AppColors.secondary.withOpacity(0.5) : null,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  onTap: () => _startRoutine(data, docId),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['name'] ?? "Sin título",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (completed)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dificultad: ${data['difficulty']}"),
                      Text("Duración: ${formatTime(data['duration'] ?? 0)}"),
                      Text("Instrucciones: ${data['instructions']}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _editRoutine(context, docId, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRoutine(context, docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _addRoutine(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
