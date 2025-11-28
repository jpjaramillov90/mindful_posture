import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getRoutinesByUser(String userId) {
    return _db
        .collection('routines')
        .where('createdBy', isEqualTo: userId)
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> addRoutine(Map<String, dynamic> data) async {
    await _db.collection('routines').add(data);
  }

  Future<void> updateRoutine(String docId, Map<String, dynamic> data) async {
    await _db.collection('routines').doc(docId).update(data);
  }

  Future<void> deleteRoutine(String docId) async {
    await _db.collection('routines').doc(docId).delete();
  }

  // --------------------
  // Resetear todas las rutinas del usuario
  // --------------------
  Future<void> resetAllRoutines(String userId) async {
    final snapshot = await _db
        .collection('routines')
        .where('createdBy', isEqualTo: userId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'completed': false});
    }
  }

  // --------------------
  // Guardar la fecha del último reset
  // --------------------
  Future<void> updateLastReset(String userId, DateTime timestamp) async {
    await _db.collection('users').doc(userId).set({
      'lastReset': timestamp,
    }, SetOptions(merge: true));
  }

  // Obtener la fecha del último reset
  Future<DateTime?> getLastReset(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('lastReset')) {
      return (doc.data()!['lastReset'] as Timestamp).toDate();
    }
    return null;
  }
}
