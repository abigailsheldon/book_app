import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';

/// Wraps OpenAI chat to return a JSON array of titles/authors.
class OpenAIService {
  Future<List<String>> getBookRecommendations({
    required List<String> genres,
    required List<String> currentTitles,
  }) async {
    final prompt = '''
You are a friendly book recommender.
The user likes these genres: ${genres.join(', ')}.
They have already indicated interest in these books: ${currentTitles.join('; ')}.
Please suggest 5 more book titles (just title and author) and return as a JSON array of strings:
["The Hobbit by J.R.R. Tolkien", …]
''';

    final chat = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,

          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
          ],
        ),
      ],
    );

    // Pull the assistant's text and parse it
    final text = chat.choices.first.message.content?.first.text;
    if (text == null) throw Exception("No response from OpenAI");

    final List<dynamic> arr = json.decode(text);
    return List<String>.from(arr);
  }
}
