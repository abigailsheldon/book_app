
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discussion_post.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

/*
 * DiscussionBoardScreen
 * Shows a threaded list of discussion posts for a given category (e.g. book ID).
 * If parentId is null, shows top-level posts; otherwise shows replies to that post.
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

  /*
   * Shows a dialog to enter a new post (or reply), then saves it to Firestore.
   */
  Future<void> _showNewPostDialog() async {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final uid = userProv.user!.uid;
    final name = userProv.user!.email ?? 'Anonymous';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.parentId == null ? 'New Post' : 'Reply to Post'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write your message here…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller.clear();
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submitting
                ? null
                : () async {
                    if (_controller.text.trim().isEmpty) return;
                    setState(() => _submitting = true);

                    final post = DiscussionPost(
                      id: '', // Firestore will assign
                      authorId: uid,
                      authorName: name,
                      category: widget.category,
                      content: _controller.text.trim(),
                      createdAt: DateTime.now(),
                      parentId: widget.parentId,
                    );

                    await _fs.addDiscussionPost(post);
                    setState(() => _submitting = false);
                    _controller.clear();
                    Navigator.of(ctx).pop();
                  },
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    // Stream posts for this category/parentId
    final stream = _fs.discussionStream(
      widget.category,
      parentId: widget.parentId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentId == null
            ? 'Discussion Board'
            : 'Replies'),
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
            itemCount: posts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final post = posts[i];
              return ListTile(
                title: Text(post.authorName),
                subtitle: Text(post.content),
                trailing: IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: () {
                    // Navigate to a threaded view of replies
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
                ),
              );
            },
          );
        },
      ),
      
      // FAB to add a new top-level post or reply
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewPostDialog,
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
