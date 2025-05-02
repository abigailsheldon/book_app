import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../providers/review_provider.dart';

/* Displays a scrollable list of reviews for one book. */
class ReviewList extends StatelessWidget {
  final Stream<List<Review>> reviewsStream;
  const ReviewList({Key? key, required this.reviewsStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: reviewsStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reviews = snap.data ?? [];
        if (reviews.isEmpty) {
          return const Center(child: Text('No reviews yet.'));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (ctx, i) {
            final r = reviews[i];
            return ListTile(
              title: Text(r.reviewerName),
              subtitle: Text(r.content),
              trailing: PopupMenuButton<String>(
                onSelected: (choice) async {
                  final prov = context.read<ReviewProvider>();
                  if (choice == 'Edit') {
                    
                    // Inline edit dialog
                    String editedContent = r.content;
                    int editedRating = r.rating;
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Edit Review'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              initialValue: r.content,
                              maxLines: 3,
                              onChanged: (v) => editedContent = v,
                              decoration: const InputDecoration(labelText: 'Review'),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: r.rating,
                              items: List.generate(5, (i) => i + 1)
                                  .map((val) => DropdownMenuItem(
                                        value: val,
                                        child: Text('$val'),
                                      ))
                                  .toList(),
                              onChanged: (v) => editedRating = v!,
                              decoration: const InputDecoration(labelText: 'Rating'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, {
                              'content': editedContent,
                              'rating': editedRating,
                            }),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                    if (result != null) {
                      // apply update
                      final updated = Review(
                        id: r.id,
                        bookId: r.bookId,
                        reviewerId: r.reviewerId,
                        reviewerName: r.reviewerName,
                        content: result['content'] as String,
                        rating: result['rating'] as int,
                        createdAt: r.createdAt,
                      );
                      await prov.updateReview(updated);
                    }
                  } else if (choice == 'Delete') {
                    await prov.deleteReview(r.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'Edit', child: Text('Edit')),
                  PopupMenuItem(value: 'Delete', child: Text('Delete')),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
