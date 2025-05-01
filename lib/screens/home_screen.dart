import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import 'book_detail_screen.dart';

/*
 * Home screen showing search bar and list of books (search results or recommendations).
 */

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    // Access BookProvider for search state
    final bookProv = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            // Search input field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search books',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      bookProv.searchBooks(query);
                    }
                  },
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (query) {
                final q = query.trim();
                if (q.isNotEmpty) bookProv.searchBooks(q);
              },
            ),

            const SizedBox(height: 16),

            // Display loading indicator
            if (bookProv.loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )

            // Display error message
            else if (bookProv.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    bookProv.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )

            // Display placeholder when no results
            else if (bookProv.searchResults.isEmpty)
              const Expanded(
                child: Center(child: Text('No books found. Try searching above.')),
              )

            // Display list of books
            else
              Expanded(
                child: ListView.builder(
                  itemCount: bookProv.searchResults.length,
                  itemBuilder: (context, index) {
                    final Book book = bookProv.searchResults[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailScreen(book: book),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: book.coverUrl.isNotEmpty
                              ? Image.network(
                                  book.coverUrl,
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                              : null,
                          title: Text(book.title),
                          subtitle: Text(book.author),
                          trailing: book.rating > 0
                              ? Text('${book.rating}/5')
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
