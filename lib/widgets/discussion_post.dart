import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discussion_post.dart';
import '../services/firestore_service.dart';

/*
 * A widget to display a single discussion post with author, timestamp,
 * content, and optional reply, edit, and delete actions.
 */
class DiscussionPostWidget extends StatelessWidget {
  final DiscussionPost post;
  final VoidCallback? onReply;

  const DiscussionPostWidget({
    Key? key,
    required this.post,
    this.onReply,
  }) : super(key: key);

  // Formats the DateTime to MM/DD/YYYY HH:MM
  String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0] : '?',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _formatTimestamp(post.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (onReply != null)
                  IconButton(
                    icon: const Icon(Icons.reply),
                    tooltip: 'Reply',
                    onPressed: onReply,
                  ),
                // Edit/Delete menu
                PopupMenuButton<String>(
                  onSelected: (choice) async {
                    final service = FirestoreService();
                    if (choice == 'Edit') {
                      String editedContent = post.content;
                      final result = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Edit Post'),
                          content: TextFormField(
                            initialValue: post.content,
                            maxLines: 3,
                            onChanged: (v) => editedContent = v,
                            decoration: const InputDecoration(
                              labelText: 'Content',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, editedContent),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                      if (result != null && result.trim().isNotEmpty) {
                        final updated = DiscussionPost(
                          id: post.id,
                          authorId: post.authorId,
                          authorName: post.authorName,
                          category: post.category,
                          content: result.trim(),
                          createdAt: post.createdAt,
                          parentId: post.parentId,
                        );
                        await service.updateDiscussionPost(updated);
                      }
                    } else if (choice == 'Delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Post?'),
                          content: const Text('Are you sure you want to delete this post?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await service.deleteDiscussionPost(post.id);
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'Edit', child: Text('Edit')),
                    PopupMenuItem(value: 'Delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
