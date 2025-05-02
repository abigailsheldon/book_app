import 'package:flutter/material.dart';
import '../models/review.dart';

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
              trailing: Text('${r.rating}/5'),
            );
          },
        );
      },
    );
  }
}
