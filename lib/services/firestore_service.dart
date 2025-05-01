/* Wraps Firestore CRUD operations for users, reviews, and discussion posts. */

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../models/discussion_post.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save or update a user profile document
  Future<void> setUser(AppUser user) {
    return _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // Fetch a user profile by UID
  Future<AppUser> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return AppUser.fromDocument(doc);
  }

  // Add a new Review to the `reviews` collection
  Future<void> addReview(Review review) {
    return _db.collection('reviews').add(review.toMap());
  }

  // Stream all reviews for a given book, most-recent first
  Stream<List<Review>> reviewsStream(String bookId) {
    return _db
        .collection('reviews')
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Review.fromDocument(doc)).toList());
  }

  // Add a new discussion post
  Future<void> addDiscussionPost(DiscussionPost post) {
    return _db.collection('discussion').add(post.toMap());
  }

  // Stream discussion posts in a category
  Stream<List<DiscussionPost>> discussionStream(String category,
      {String? parentId}) {
    Query query =
        _db.collection('discussion').where('category', isEqualTo: category);
    if (parentId != null) {
      query = query.where('parentId', isEqualTo: parentId);
    }
    return query
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => DiscussionPost.fromDocument(doc)).toList());
  }
}
