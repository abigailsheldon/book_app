
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/review_provider.dart';
import '../widgets/review_list.dart';
import 'review_screen.dart';
// import 'discussion_board_screen.dart'; // TODO: create this screen

/*
 * Displays all metadata for a single book, plus reviews and actions.
 */

class BookDetailScreen extends StatelessWidget {
  final Book book;

  /*
   * Constructs the details page for [book].
   */
  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the ReviewProvider to fetch review streams
    final reviewProvider = context.read<ReviewProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Book cover image 
            if (book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty)
              Center(
                child: Image.network(
                  book.coverImageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            // Title and author(s)
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (book.authors != null && book.authors!.isNotEmpty)
              Text(
                'by ${book.authors!.join(', ')}',
                style: Theme.of(context).textTheme.titleMedium,
              ),

            const SizedBox(height: 8),

            // Average rating display
            if (book.averageRating != null)
              Row(
                children: [
                  const Icon(Icons.star, size: 20),
                  const SizedBox(width: 4),
                  Text('${book.averageRating} / 5'),
                ],
              ),

            const SizedBox(height: 16),

            // Book description / summary
            if (book.description != null)
              Text(
                book.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

            const SizedBox(height: 24),

            // Action buttons: write review, go to discussion
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      
                      // Navigate to ReviewScreen to submit a new review
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewScreen(book: book),
                        ),
                      );
                    },
                    child: const Text('Write a Review'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      
                      // TODO: implement and navigate to discussion board screen
                      // Navigator.push(context,
                      //   MaterialPageRoute(builder: (_) => DiscussionBoardScreen(category: book.id)));
                    },
                    child: const Text('Discussion Board'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section header for existing reviews
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // ReviewList widget displays a real-time stream of reviews
            ReviewList(
              reviewsStream: reviewProvider.reviewsFor(book.id),
            ),
          ],
        ),
      ),
    );
  }
}
