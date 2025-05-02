// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /*
   * Attempts to sign in with email & password.
   * Returns the Firebase [User] on success.
   */
  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /*
   * Creates a new account with email & password.
   * Returns the Firebase [User] on success.
   */
  Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /*
   * Signs out the current user.
   */
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
