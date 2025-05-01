/*
 * Manages reviews: exposes a stream of reviews for a book and
 * provides a method to add a new one.
 */
import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/firestore_service.dart';

class ReviewProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();

  // Returns a stream of reviews for [bookId], ordered newest first.
  Stream<List<Review>> reviewsFor(String bookId) {
    return _fs.reviewsStream(bookId);
  }

  // Adds a new review to Firestore.
  Future<void> addReview(Review review) => _fs.addReview(review);
}
