import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login con email y contraseña
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // OK
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  /// Registro de usuario con email, contraseña y datos adicionales
  Future<String?> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      // Guardar datos adicionales en Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'lastName': lastName,
        'email': email,
        'createdAt': DateTime.now(),
      });

      return null; // OK
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Obtener datos del usuario actual desde Firestore
  Future<Map<String, dynamic>> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return {'name': '', 'lastName': ''};

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data() ?? {'name': '', 'lastName': ''};
  }

  /// Stream de cambios en la autenticación
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
