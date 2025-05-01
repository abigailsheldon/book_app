/*
 * Represents an app user and serializes to/from Firestore.
 * 
 * Stores uid (user id), email, display name, fav. genres, and reading lists
 */
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final List<String> favoriteGenres;
  final List<String> readingListWantToRead;
  final List<String> readingListReading;
  final List<String> readingListFinished;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.favoriteGenres = const [],
    this.readingListWantToRead = const [],
    this.readingListReading = const [],
    this.readingListFinished = const [],
  });

  /*
   * Convert an AppUser instance to a Map for Firestore.
   */
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'favoriteGenres': favoriteGenres,
      'readingList': {
        'wantToRead': readingListWantToRead,
        'reading': readingListReading,
        'finished': readingListFinished,
      },
    };
  }

  /*
   * Construct AppUser from a Firestore DocumentSnapshot.
   */
  factory AppUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final reading = data['readingList'] as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: data['uid'],
      email: data['email'],
      displayName: data['displayName'],
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? []),
      readingListWantToRead: List<String>.from(reading['wantToRead'] ?? []),
      readingListReading: List<String>.from(reading['reading'] ?? []),
      readingListFinished: List<String>.from(reading['finished'] ?? []),
    );
  }
}