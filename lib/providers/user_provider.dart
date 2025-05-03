import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user.dart';

/*
 * Manages authentication and user profile state, including reading lists.
 */
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestore = FirestoreService();
  User? _firebaseUser;
  AppUser? _appUser;
  String? errorMessage;

  // The raw Firebase user
  User? get user => _firebaseUser;

  // The extended profile from Firestore
  AppUser? get appUser => _appUser;

  /*
   * login: Calls AuthService.signIn, loads Firestore profile on success.
   * Returns true if success, false otherwise.
   */
  Future<bool> login(String email, String password) async {
    try {
      _firebaseUser = await _authService.signIn(email, password);
      errorMessage = null;
      await _loadProfile();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /*
   * signup: Calls AuthService.signUp, creates Firestore profile on success.
   * Returns true if success, false otherwise.
   */
  Future<bool> signup(String email, String password) async {
    try {
      _firebaseUser = await _authService.signUp(email, password);
      
      // Create a default Firestore profile
      final defaultUser = AppUser(
        uid: _firebaseUser!.uid,
        email: _firebaseUser!.email!,
        displayName: _firebaseUser!.displayName,
        favoriteGenres: [],
        readingListWantToRead: [],
        readingListReading: [],
        readingListFinished: [],
      );

      await _firestore.setUser(defaultUser);
      _appUser = defaultUser;
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
   * logout: Calls AuthService.signOut and clears state.
   */
  Future<void> logout() async {
    await _authService.signOut();
    _firebaseUser = null;
    _appUser = null;
    notifyListeners();
  }

  // Loads the Firestore profile for the current Firebase user.
  Future<void> _loadProfile() async {
    if (_firebaseUser == null) return;
    try {
      _appUser = await _firestore.getUser(_firebaseUser!.uid);
    } catch (e) {
      errorMessage = 'Failed to load profile: $e';
    } finally {
      notifyListeners();
    }
  }

  /*
   * Updates the user's reading lists by moving [bookId] into [target]
   * ('Want to Read', 'Reading', 'Finished') or removing it.
   */
  Future<void> updateReadingList(String bookId, String target) async {
    if (_appUser == null) return;
    
    // Copy lists
    final want = List<String>.from(_appUser!.readingListWantToRead);
    final reading = List<String>.from(_appUser!.readingListReading);
    final finished = List<String>.from(_appUser!.readingListFinished);
    
    // Remove from all
    want.remove(bookId);
    reading.remove(bookId);
    finished.remove(bookId);
    
    // Add to target
    switch (target) {
      case 'Want to Read':
        want.add(bookId);
        break;
      case 'Reading':
        reading.add(bookId);
        break;
      case 'Finished':
        finished.add(bookId);
        break;
      case 'Remove':
      default:
        break;
    }
    // Persist
    final updated = AppUser(
      uid: _appUser!.uid,
      email: _appUser!.email,
      displayName: _appUser!.displayName,
      favoriteGenres: _appUser!.favoriteGenres,
      readingListWantToRead: want,
      readingListReading: reading,
      readingListFinished: finished,
    );
    try {
      await _firestore.setUser(updated);
      _appUser = updated;
    } catch (e) {
      errorMessage = 'Could not update list: $e';
    } finally {
      notifyListeners();
    }
  }
}