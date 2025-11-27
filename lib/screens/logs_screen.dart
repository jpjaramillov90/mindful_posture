import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case "bad_posture":
        return Icons.warning_amber_rounded;
      case "good_posture":
        return Icons.check_circle_outline;
      case "too_close":
        return Icons.visibility_off;
      case "correct_distance":
        return Icons.visibility;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case "bad_posture":
      case "too_close":
        return Colors.red;
      case "good_posture":
      case "correct_distance":
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return "--/--/---- --:--";

    final dt = ts.toDate();
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Actividad")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("logs")
            .where("userId", isEqualTo: user?.uid)
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar los registros."));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Aún no tienes registros.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final log = docs[index];
              final type = log["type"] ?? "unknown";
              final message = log["message"] ?? "";
              final timestamp = log["timestamp"] as Timestamp?;

              return Card(
                elevation: 3,
                child: ListTile(
                  leading: Icon(
                    _getIcon(type),
                    color: _getColor(type),
                    size: 32,
                  ),
                  title: Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_formatDate(timestamp)),
                  trailing: Text(
                    type.replaceAll("_", " "),
                    style: TextStyle(
                      color: _getColor(type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
