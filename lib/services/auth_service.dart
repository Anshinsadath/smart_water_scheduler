import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // REGISTER
  static Future<User?> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // LOGIN
  static Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // CURRENT USER
  static User? get currentUser => _auth.currentUser;
}
