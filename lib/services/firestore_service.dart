import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener rutinas desde Firestore
  Stream<QuerySnapshot> getRoutines() {
    return _db.collection('routines').snapshots();
  }
}
