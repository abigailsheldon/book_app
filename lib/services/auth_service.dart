/*
 * Provides authentication methods.
 */

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /*
   * signIn: Attempts to authenticate  user with provided email & password.
   * Returns a Firebase User on success, or throws an error if authentication fails.
   */
  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /*
   * signUp: Creates a new user account with given email and password.
   * Returns a Firebase User on success, or throws an error if account creation fails.
   */
  Future<User?> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /*
   * signOut: Logs out the currently authenticated user.
   */
  Future<void> signOut() async {
    await _auth.signOut();
  }
}