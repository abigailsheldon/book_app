import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a user profile in Firestore.
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
    required this.favoriteGenres,
    required this.readingListWantToRead,
    required this.readingListReading,
    required this.readingListFinished,
  });

  // Convert Firestore document snapshot into an [AppUser].
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? <String>[]),
      readingListWantToRead: List<String>.from(data['readingListWantToRead'] ?? <String>[]),
      readingListReading: List<String>.from(data['readingListReading'] ?? <String>[]),
      readingListFinished: List<String>.from(data['readingListFinished'] ?? <String>[]),
    );
  }

  // Convert this [AppUser] into a map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'favoriteGenres': favoriteGenres,
      'readingListWantToRead': readingListWantToRead,
      'readingListReading': readingListReading,
      'readingListFinished': readingListFinished,
    };
  }
}
