import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/review_provider.dart';
import '../widgets/review_list.dart';
import 'review_screen.dart';
import 'discussion_board_screen.dart';

/*
 * Displays all metadata for a single book, plus reviews and actions.
 */
class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({Key? key, required this.book}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final reviewProv = context.read<ReviewProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Cover
          if (book.coverUrl.isNotEmpty)
            Center(
                child:
                    Image.network(book.coverUrl, height: 200, fit: BoxFit.cover)),
          const SizedBox(height: 16),
          // Title & Author
          Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('by ${book.author}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // Rating
          if (book.rating > 0)
            Row(children: [
              const Icon(Icons.star, size: 20),
              const SizedBox(width: 4),
              Text('${book.rating}/5')
            ]),
          const SizedBox(height: 16),
          // Description
          if (book.description.isNotEmpty)
            Text(book.description,
                style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          // Actions
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ReviewScreen(book: book)),
                        ),
                    child: const Text('Write a Review'))),
            const SizedBox(width: 12),
            Expanded(
                child: OutlinedButton(
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  DiscussionBoardScreen(category: book.id)),
                        ),
                    child: const Text('Discussion Board'))),
          ]),
          const SizedBox(height: 32),
          Text('Reviews', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ReviewList(reviewsStream: reviewProv.reviewsFor(book.id)),
        ]),
      ),
    );
  }
}
