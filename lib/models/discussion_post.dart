import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a discussion post or reply stored in Firestore.
class DiscussionPost {
  final String id;
  final String authorId;
  final String authorName;
  final String category;
  final String content;
  final DateTime createdAt;
  final String? parentId;

  DiscussionPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.category,
    required this.content,
    required this.createdAt,
    this.parentId,
  });

  /// Creates a DiscussionPost from a Firestore document snapshot.
  factory DiscussionPost.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DiscussionPost(
      id: doc.id,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      category: data['category'] as String,
      content: data['content'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      parentId: data['parentId'] as String?,
    );
  }

  // Converts this DiscussionPost into a map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'category': category,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'parentId': parentId,
    };
  }
}
