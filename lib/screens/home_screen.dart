import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

/*
 * Home screen showing search bar, list of books, and a Drawer
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
    final bookProv = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      
      // Add a navigation drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text('Menu')),
            
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
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
              onTap: () => Navigator.pushNamed(context, '/reading-list'),
            ),
            
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),

      // Body scrollable and avoid keyboard overflow
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                  if (q.trim().isNotEmpty) bookProv.searchBooks(q.trim());
                },
              ),
              const SizedBox(height: 16),

              // Loading / Error / Empty / List states
              if (bookProv.loading)
                const Center(child: CircularProgressIndicator())
              else if (bookProv.error != null)
                Center(child: Text(bookProv.error!, style: const TextStyle(color: Colors.red)))
              else if (bookProv.searchResults.isEmpty)
                const Center(child: Text('No books found. Try searching above.'))
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
                        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
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
