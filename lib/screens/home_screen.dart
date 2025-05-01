import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
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
  @override void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final bookProv = Provider.of<BookProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
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
          // States
          if (bookProv.loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (bookProv.error != null)
            Expanded(
              child: Center(
                  child: Text(bookProv.error!,
                      style: const TextStyle(color: Colors.red))),
            )
          else if (bookProv.searchResults.isEmpty)
            const Expanded(
                child:
                    Center(child: Text('No books found. Try searching above.')))
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
                      MaterialPageRoute(
                          builder: (_) => BookDetailScreen(book: book)),
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
