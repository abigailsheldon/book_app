/*
 * Represents a book review submitted by user and serializes to/from Firestore.
 * Review fields:
 * id, bookId, reviewerId, revieewrName, rating, content, createdAt
 */ 

import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String bookId;
  final String reviewerId;
  final String reviewerName;
  final int rating;
  final String content;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  /*
   * Convert Review instance to Map for Firestore storage.
   */
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'rating': rating,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /*
   * Create a Review from Firestore DocumentSnapshot.
   */
  factory Review.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      bookId: data['bookId'],
      reviewerId: data['reviewerId'],
      reviewerName: data['reviewerName'],
      rating: data['rating'] as int,
      content: data['content'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}