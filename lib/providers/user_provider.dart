import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/*
 * Manages authentication state for app, exposing login, signup, and logout.
 */

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? errorMessage;

  /*
   * Exposes the current Firebase user, or null if not authenticated.
   */
  User? get user => _user;

  /*
   * login: Calls AuthService.signIn and updates state.
   * Returns true if success, false otherwise.
   */
  Future<bool> login(String email, String password) async {
    try {
      _user = await _authService.signIn(email, password);
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /*
   * signup: Calls AuthService.signUp and updates state.
   * Returns true if success, false otherwise.
   */
  Future<bool> signup(String email, String password) async {
    try {
      _user = await _authService.signUp(email, password);
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /*
   * logout: Calls AuthService.signOut and clears user state.
   */
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}