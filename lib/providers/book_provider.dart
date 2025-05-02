import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/google_books_service.dart';

/* 
 * Manages book search (and eventually recommendations) state.
 */
class BookProvider extends ChangeNotifier {
  final GoogleBooksService _booksService = GoogleBooksService();

  List<Book> _searchResults = [];
  bool _loading = false;
  String? _error;

  List<Book> get searchResults => _searchResults;
  bool get loading => _loading;
  String? get error => _error;

  /// Search Google Books for [query] and update state.
  Future<void> searchBooks(String query) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _booksService.searchBooks(query);

      if (results.isEmpty) {
        _searchResults = [];
        _error = 'No books found for “$query”.';
      } else {
        _searchResults = results;
      }
    } catch (e) {
      _searchResults = [];
      _error = 'Failed to fetch books: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Clear last results and any error.
  void clear() {
    _searchResults = [];
    _error = null;
    notifyListeners();
  }
}
