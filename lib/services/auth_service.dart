import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  // REGISTER
  static Future<void> register({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGIN (only registered users)
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }
}
