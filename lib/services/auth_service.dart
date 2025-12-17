import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<User?> signInAnonymously() async {
    try {
      final userCred = await _auth.signInAnonymously();
      return userCred.user;
    } catch (e) {
      // Firebase not available, return null
      print('Auth sign in failed: $e');
      return null;
    }
  }

  static User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      // Firebase not available
      print('Auth current user failed: $e');
      return null;
    }
  }
}
