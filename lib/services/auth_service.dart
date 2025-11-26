import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registrar usuario
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // todo bien
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Iniciar sesión
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Saber si hay un usuario logueado
  Stream<User?> get userStream => _auth.authStateChanges();
}
