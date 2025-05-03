import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a book review stored in Firestore.
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

  // Creates a Review from a Firestore document snapshot.
  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Review(
      id: doc.id,
      bookId: data['bookId'] as String,
      reviewerId: data['reviewerId'] as String,
      reviewerName: data['reviewerName'] as String,
      rating: (data['rating'] as num).toInt(),
      content: data['content'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Converts this Review into a map for saving to Firestore.
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
}
