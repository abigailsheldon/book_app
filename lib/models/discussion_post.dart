import 'package:cloud_firestore/cloud_firestore.dart';

/*
 * Represents a single post in a discussion board and serializes to/from Firestore.
 */

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

  /*
   * Convert a DiscussionPost to a Map for Firestore storage.
   */
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

  /*
   * Create a DiscussionPost from a Firestore DocumentSnapshot.
   */
  factory DiscussionPost.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiscussionPost(
      id: doc.id,
      authorId: data['authorId'],
      authorName: data['authorName'],
      category: data['category'],
      content: data['content'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      parentId: data['parentId'],
    );
  }
}