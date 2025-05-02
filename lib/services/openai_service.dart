// lib/services/openai_service.dart

import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';

/// Wraps OpenAI chat to return a JSON array of book recommendations
/// in the form "Title by Author".
class OpenAIService {
  Future<List<String>> getBookRecommendations({
    required List<String> genres,
    required List<String> currentTitles,
  }) async {
    final prompt = '''
You are a friendly book recommender.
The user likes these genres: ${genres.join(', ')}.
They have already indicated interest in these books: ${currentTitles.join('; ')}.
Please suggest 5 more book titles (just title and author) and return as a JSON array of strings, e.g.:
["The Hobbit by J.R.R. Tolkien", "Dune by Frank Herbert", …]
''';

    // Use the Chat API with GPT-4.1 (or swap to gpt-3.5-turbo)
    final chat = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-16k",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
          ],
        ),
      ],
    );

    // Pull out the text safely
    final contentItems = chat.choices.first.message.content;
    if (contentItems == null || contentItems.isEmpty) {
      throw Exception("OpenAI returned no content");
    }
    final rawText = contentItems.first.text;
    if (rawText == null || rawText.trim().isEmpty) {
      throw Exception("OpenAI returned empty text");
    }
    final responseText = rawText.trim();

    // Parse as JSON array
    final List<dynamic> arr = json.decode(responseText);
    return List<String>.from(arr);
  }
}
