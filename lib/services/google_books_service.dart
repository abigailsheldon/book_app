import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/book.dart';
import 'package:flutter/foundation.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /*
   * Search Google Books. If an API key is present, append it.
   */
  Future<List<Book>> searchBooks(String query) async {
    final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'];
    
    // Build the URL string
    final encodedQuery = Uri.encodeComponent(query);
    final url = apiKey != null && apiKey.isNotEmpty
      ? '$_baseUrl?q=$encodedQuery&key=$apiKey'
      : '$_baseUrl?q=$encodedQuery';

    // Debug
    debugPrint('GoogleBooks → GET $url');

    final uri = Uri.parse(url);
    final response = await http.get(uri);

    // Debug
    debugPrint('GoogleBooks ← ${response.statusCode}: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch books: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>?;

    if (items == null) return [];

    return items
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Book> getBookById(String id) async {
    final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'];
    final url = apiKey != null && apiKey.isNotEmpty
        ? '$_baseUrl/$id?key=$apiKey'
        : '$_baseUrl/$id';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) throw Exception('Book not found');
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return Book.fromJson(data);
  }
  
}
