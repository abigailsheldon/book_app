import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/book.dart';

/*
 * Provides methods to search for books via the Google Books API.
 */

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /*
   * searchBooks: Performs a GET request to the Google Books API with the given [query].
   * Parses the JSON response and returns a list of Book objects.
   */
  Future<List<Book>> searchBooks(String query) async {
    final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'];
    final uri = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(query)}'
      '\${apiKey != null && apiKey.isNotEmpty ? '&key=$apiKey' : ''}',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch books: \${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>?;
    if (items == null) return [];

    return items
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
