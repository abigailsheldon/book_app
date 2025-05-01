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

  // Search Google Books for [query] and update state.
  Future<void> searchBooks(String query) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _booksService.searchBooks(query);
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  // Clear last results
  void clear() {
    _searchResults = [];
    _error = null;
    notifyListeners();
  }
}
