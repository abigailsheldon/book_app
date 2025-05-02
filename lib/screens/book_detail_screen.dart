import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/review_provider.dart';
import '../providers/user_provider.dart';
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
    final userProv = context.watch<UserProvider>();
    final appUser = userProv.appUser;
    final bookId = book.id;
    
    // Determine if this book is in each list
    final inWant = appUser?.readingListWantToRead.contains(bookId) ?? false;
    final inReading = appUser?.readingListReading.contains(bookId) ?? false;
    final inFinished = appUser?.readingListFinished.contains(bookId) ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            if (book.coverUrl.isNotEmpty)
              Center(
                child: Image.network(
                  book.coverUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            
            // Title & Author
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'by ${book.author}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // Rating
            if (book.rating > 0)
              Row(
                children: [
                  const Icon(Icons.star, size: 20),
                  const SizedBox(width: 4),
                  Text('${book.rating}/5'),
                ],
              ),
            const SizedBox(height: 16),
            
            // Description
            if (book.description.isNotEmpty)
              Text(
                book.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 24),
            
            // Reading List Buttons
            Text(
              'Add to your reading list:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    inWant ? Icons.check : Icons.bookmark_outline,
                  ),
                  label: Text(
                    inWant ? 'In Want to Read' : 'Want to Read',
                  ),
                  onPressed: () => userProv.updateReadingList(
                    bookId,
                    inWant ? 'Remove' : 'Want to Read',
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    inReading ? Icons.check : Icons.menu_book,
                  ),
                  label: Text(
                    inReading ? 'In Reading' : 'Reading',
                  ),
                  onPressed: () => userProv.updateReadingList(
                    bookId,
                    inReading ? 'Remove' : 'Reading',
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    inFinished ? Icons.check : Icons.done_all,
                  ),
                  label: Text(
                    inFinished ? 'In Finished' : 'Finished',
                  ),
                  onPressed: () => userProv.updateReadingList(
                    bookId,
                    inFinished ? 'Remove' : 'Finished',
                  ),
                ),
              ],
            ),
            if (userProv.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  userProv.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 32),
            
            // Existing action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewScreen(book: book),
                      ),
                    ),
                    child: const Text('Write a Review'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DiscussionBoardScreen(category: book.id),
                      ),
                    ),
                    child: const Text('Discussion Board'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ReviewList(reviewsStream: reviewProv.reviewsFor(book.id)),
          ],
        ),
      ),
    );
  }
}
