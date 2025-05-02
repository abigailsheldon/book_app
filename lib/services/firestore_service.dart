import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../models/user.dart';
import '../models/review.dart';
import '../models/discussion_post.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; 

  // Fetches the AppUser doc, or makes a blank one if missing.
  Future<AppUser> getUser(String uid) async {
    final docRef = _db.collection('users').doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      
      // No document yet, create a default one
      final firebaseUser = _auth.currentUser!;
      final defaultUser = AppUser(
        uid: uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        favoriteGenres: [],
        readingListWantToRead: [],
        readingListReading: [],
        readingListFinished: [],
      );
      await docRef.set(defaultUser.toMap());
      return defaultUser;
    }
    return AppUser.fromFirestore(snapshot);
  }

  // Writes (or overwrites) the user document.
  Future<void> setUser(AppUser user) =>
      _db.collection('users').doc(user.uid).set(user.toMap());

  // Adds a new review under 'reviews' collection.
  Future<void> addReview(Review review) =>
      _db.collection('reviews').add(review.toMap());

  // Streams reviews for a given bookId.
  Stream<List<Review>> reviewsFor(String bookId) {
    return _db
        .collection('reviews')
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  // Alias
  Stream<List<Review>> reviewsStream(String bookId) => reviewsFor(bookId);

  // Adds discussion post.
  Future<void> addDiscussionPost(DiscussionPost post) =>
      _db.collection('discussions').add(post.toMap());

  // Streams discussion posts by category/parent.
  Stream<List<DiscussionPost>> discussionStream(
      String category, {String? parentId}) {
    var query = _db
        .collection('discussions')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: false);
    if (parentId != null) {
      query = query.where('parentId', isEqualTo: parentId);
    } else {
      query = query.where('parentId', isNull: true);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => DiscussionPost.fromFirestore(doc)).toList());
  }

  /* Delete/edit posts */

  // Reviews
  Future<void> updateReview(Review review) =>
    _db.collection('reviews').doc(review.id).update(review.toMap());

  Future<void> deleteReview(String reviewId) =>
    _db.collection('reviews').doc(reviewId).delete();

  // Discussion posts
  Future<void> updateDiscussionPost(DiscussionPost post) =>
    _db.collection('discussions').doc(post.id).update(post.toMap());

  Future<void> deleteDiscussionPost(String postId) =>
    _db.collection('discussions').doc(postId).delete();
}