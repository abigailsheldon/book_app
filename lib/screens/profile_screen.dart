import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import 'book_detail_screen.dart';

/*
 * ProfileScreen
 * Displays user info and their reading lists with book details.
 */
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final bookProv = context.watch<BookProvider>();
    final appUser = userProv.appUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: appUser == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${appUser.email}'),
                      const SizedBox(height: 8),
                      Text('Display Name: ${appUser.displayName ?? '—'}'),
                      const SizedBox(height: 8),
                      Text(
                        'Favorite Genres: ${appUser.favoriteGenres.isEmpty ? '—' : appUser.favoriteGenres.join(', ')}',
                      ),
                      const Divider(height: 32),

                      _buildSection(
                        context,
                        title: 'Want to Read',
                        ids: appUser.readingListWantToRead,
                        bookProv: bookProv,
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        title: 'Reading',
                        ids: appUser.readingListReading,
                        bookProv: bookProv,
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        title: 'Finished',
                        ids: appUser.readingListFinished,
                        bookProv: bookProv,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<String> ids,
    required BookProvider bookProv,
  }) {
    if (ids.isEmpty) {
      return Text('$title: (none)');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: FutureBuilder<List<Book>>(
            future: Future.wait(ids.map((id) => bookProv.fetchBookById(id))),
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Text(
                  'Error: ${snap.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }
              final books = snap.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (itemCtx, i) {
                  final book = books[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      itemCtx,
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(book: book),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (book.coverUrl.isNotEmpty)
                          Image.network(
                            book.coverUrl,
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        else
                          const SizedBox(width: 80, height: 100),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 80,
                          child: Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
