import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discussion_post.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/discussion_post.dart';

/*
 * Discussion board and threaded replies
 */
class DiscussionBoardScreen extends StatefulWidget {
  final String category;
  final String? parentId;
  const DiscussionBoardScreen({
    Key? key,
    required this.category,
    this.parentId,
  }) : super(key: key);

  @override
  State<DiscussionBoardScreen> createState() => _DiscussionBoardScreenState();
}

class _DiscussionBoardScreenState extends State<DiscussionBoardScreen> {
  final FirestoreService _fs = FirestoreService();
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showNewPostDialog({
    String? existingContent,
    void Function(String)? onSave,
  }) async {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final uid = userProv.user!.uid;
    final name = userProv.user!.email!;
    String content = existingContent ?? '';
    _controller.text = content;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existingContent == null
              ? (widget.parentId == null ? 'New Post' : 'Reply to Post')
              : 'Edit Post',
        ),
        content: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 4,
          onChanged: (v) => content = v,
          decoration: const InputDecoration(hintText: 'Write your message…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submitting
                ? null
                : () async {
                    if (content.trim().isEmpty) return;
                    setState(() => _submitting = true);
                    if (existingContent != null && onSave != null) {
                      onSave(content.trim());
                    } else {
                      final post = DiscussionPost(
                        id: '',
                        authorId: uid,
                        authorName: name,
                        category: widget.category,
                        content: content.trim(),
                        createdAt: DateTime.now(),
                        parentId: widget.parentId,
                      );
                      await _fs.addDiscussionPost(post);
                    }
                    setState(() => _submitting = false);
                    Navigator.of(ctx).pop();
                    _controller.clear();
                  },
            child: _submitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(existingContent != null ? 'Save' : 'Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = _fs.discussionStream(
      widget.category,
      parentId: widget.parentId,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.parentId == null ? 'Discussion Board' : 'Replies',
        ),
      ),
      body: StreamBuilder<List<DiscussionPost>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: posts.length,
            itemBuilder: (ctx, i) {
              final post = posts[i];
              return DiscussionPostWidget(
                post: post,
                onReply: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiscussionBoardScreen(
                        category: widget.category,
                        parentId: post.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPostDialog(),
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}