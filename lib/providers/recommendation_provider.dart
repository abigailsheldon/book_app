// lib/providers/recommendation_provider.dart

import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/openai_service.dart';
import '../services/google_books_service.dart';

// Provides AI‐driven book recommendations.
class RecommendationProvider extends ChangeNotifier {
  final OpenAIService _ai = OpenAIService();
  final GoogleBooksService _books = GoogleBooksService();

  bool loading = false;
  String? error;
  List<Book> recommendations = [];

  /* Fetches recommendations based on [genres] and the user’s
   * existing book IDs ([existingBookIds])
   */ 
  Future<void> fetchRecommendations({
    required List<String> genres,
    required List<String> existingBookIds,
  }) async {
    loading = true;
    error = null;
    recommendations = [];
    notifyListeners();

    try {
      // Ask OpenAI for a list of new titles/authors
      final recs = await _ai.getBookRecommendations(
        genres: genres,
        currentTitles: existingBookIds, // pass through to the AI prompt
      );

      // For each "Title by Author", search Google Books and pick the top result
      final results = <Book>[];
      for (final rec in recs) {
        final title = rec.split(' by ').first;
        final list = await _books.searchBooks(title);
        if (list.isNotEmpty) {
          results.add(list.first);
        }
      }
      recommendations = results;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
