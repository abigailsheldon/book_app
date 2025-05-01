import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

/*
 * Dedicated screen to search for books using Google Books API.
 * Utilizes BookProvider to perform searches and display results via BookCard.
 */
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProv = Provider.of<BookProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Search Books'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Enter title or author',
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
              final query = q.trim();
              if (query.isNotEmpty) bookProv.searchBooks(query);
            },
          ),
          const SizedBox(height: 16),
          if (bookProv.loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (bookProv.error != null)
            Expanded(
              child: Center(
                child: Text(bookProv.error!, style: const TextStyle(color: Colors.red)),
              ),
            )
          else if (bookProv.searchResults.isEmpty)
            const Expanded(
                child: Center(child: Text('No results. Try a different query.')))
          else
            Expanded(
              child: ListView.builder(
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
            ),
        ]),
      ),
    );
  }
}
