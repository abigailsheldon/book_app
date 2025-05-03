import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/discussion_post.dart';

class DiscussionProvider with ChangeNotifier {
  final _fs = FirestoreService();

  Stream<List<DiscussionPost>> stream(String category, {String? parent}) =>
    _fs.discussionStream(category, parentId: parent);

  Future<void> addPost(DiscussionPost p) =>
    _fs.addDiscussionPost(p);

  Future<void> updatePost(DiscussionPost p) =>
    _fs.updateDiscussionPost(p);

  Future<void> deletePost(String id) =>
    _fs.deleteDiscussionPost(id);
}
