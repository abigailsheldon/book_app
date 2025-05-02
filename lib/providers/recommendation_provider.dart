import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../services/google_books_service.dart';
import '../models/book.dart';

import 'package:dart_openai/dart_openai.dart';

import 'package:openai_package/openai_package.dart';
import 'package:openai_package/src/openai/import/importAi.dart';


class RecommendationProvider extends ChangeNotifier {
  final _openAI = OpenAIService();
  final _books = GoogleBooksService();

  bool loading = false;
  String? error;
  List<Book> recommendations = [];

  Future<void> fetchRecommendations({
    required List<String> genres,
    required List<String> existingBookIds,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // First get plain titles
      final titles = await _openAI.getBookRecommendations(
        genres: genres,
        existingTitles: existingBookIds,
      );

      // Then fetch full Book objects via Google Books
      final List<Book> books = [];
      for (var title in titles) {
        final hits = await _books.searchBooks(title);
        if (hits.isNotEmpty) books.add(hits.first);
      }
      recommendations = books;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}