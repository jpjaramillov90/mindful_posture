import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addLog(String type, String message) async {
    final user = FirebaseAuth.instance.currentUser;

    await db.collection("logs").add({
      "type": type,
      "message": message,
      "timestamp": FieldValue.serverTimestamp(),
      "userId": user?.uid,
    });
  }
}
