import 'package:flutter/material.dart';
import '../models/discussion_post.dart';

/*
 * A widget to display a single discussion post with author, timestamp,
 * content, and an optional reply button.
 */

class DiscussionPostWidget extends StatelessWidget {
  
  // The discussion post data to display
  final DiscussionPost post;
  
  // Optional callback when the reply button is tapped
  final VoidCallback? onReply;

  const DiscussionPostWidget({
    Key? key,
    required this.post,
    this.onReply,
  }) : super(key: key);

  // Formats the DateTime to a simple MM/DD/YYYY HH:MM string
  String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '\$month/\$day/\$year \$hour:\$minute';
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
            
            // Header row: avatar, author name, timestamp, reply icon
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
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        _formatTimestamp(post.createdAt),
                        style: Theme.of(context).textTheme.caption,
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
              ],
            ),
            const SizedBox(height: 8),
            
            // Post content text
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }
}