import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import '../services/firestore_service.dart';
import 'book_detail_screen.dart';

/*
 * ProfileScreen
 * Displays user info and their reading lists with book details.
 */
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  AppUser? _appUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      try {
        final data = await FirestoreService().getUser(user.uid);
        setState(() {
          _appUser = data;
          _loading = false;
        });
      } catch (e) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProv = context.watch<BookProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${_appUser?.email ?? ''}'),
                    const SizedBox(height: 8),
                    Text('Display Name: ${_appUser?.displayName ?? '—'}'),
                    const SizedBox(height: 8),
                    Text(
                      'Favorite Genres: ${_appUser?.favoriteGenres.join(', ') ?? '—'}',
                    ),
                    const Divider(height: 32),
                    _buildSection(
                      title: 'Want to Read',
                      ids: _appUser?.readingListWantToRead ?? [],
                      bookProv: bookProv,
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Reading',
                      ids: _appUser?.readingListReading ?? [],
                      bookProv: bookProv,
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Finished',
                      ids: _appUser?.readingListFinished ?? [],
                      bookProv: bookProv,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection({
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
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: FutureBuilder<List<Book>>(
            future: Future.wait(ids.map((id) => bookProv.fetchBookById(id))),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Text('Error: ${snap.error}',
                    style: const TextStyle(color: Colors.red));
              }
              final books = snap.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final book = books[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(book: book),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (book.coverUrl.isNotEmpty)
                          Image.network(
                            book.coverUrl,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 80,
                          child: Text(
                            book.title,
                            maxLines: 3,
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
