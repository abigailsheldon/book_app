import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/user_provider.dart';

import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

/*
 * Home screen showing search bar, list of books, AI suggestions, and a Drawer
 * to navigate to the other pages.
 */
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProv = context.watch<BookProvider>();
    final recProv = context.watch<RecommendationProvider>();
    final userProv = context.watch<UserProvider>();

    // Use Firestore-backed AppUser model
    final appUser = userProv.appUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              onTap: () => Navigator.pushNamed(context, '/search'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Reading List'),
              onTap: () =>
                  Navigator.pushNamed(context, '/reading-list'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search books',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      final q = _searchController.text.trim();
                      if (q.isNotEmpty) bookProv.searchBooks(q);
                    },
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (q) {
                  final t = q.trim();
                  if (t.isNotEmpty) bookProv.searchBooks(t);
                },
              ),
              const SizedBox(height: 24),

              // AI Suggestions section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Suggestions',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: appUser == null || recProv.loading
                        ? null
                        : () => recProv.fetchRecommendations(
                              genres: appUser.favoriteGenres,
                              existingBookIds: [
                                ...appUser.readingListWantToRead,
                                ...appUser.readingListReading,
                                ...appUser.readingListFinished,
                              ],
                            ),
                    child: recProv.loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (recProv.error != null)
                Text(recProv.error!,
                    style: const TextStyle(color: Colors.red)),
              if (recProv.recommendations.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                    itemCount: recProv.recommendations.length,
                    itemBuilder: (_, i) {
                      final book = recProv.recommendations[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookDetailScreen(book: book),
                          ),
                        ),
                        child: Column(
                          children: [
                            Image.network(book.coverUrl,
                                width: 100,
                                height: 120,
                                fit: BoxFit.cover),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 100,
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
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Search results / loading / errors
              if (bookProv.loading)
                const Center(child: CircularProgressIndicator())
              else if (bookProv.error != null)
                Center(
                  child: Text(bookProv.error!,
                      style: const TextStyle(color: Colors.red)),
                )
              else if (bookProv.searchResults.isEmpty)
                const Center(
                    child:
                        Text('No books found. Try searching above.'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookProv.searchResults.length,
                  itemBuilder: (ctx, i) {
                    final book = bookProv.searchResults[i];
                    return BookCard(
                      book: book,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                BookDetailScreen(book: book)),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
