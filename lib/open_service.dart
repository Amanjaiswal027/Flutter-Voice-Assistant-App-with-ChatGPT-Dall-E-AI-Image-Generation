import 'dart:convert';
import 'package:currency_converter/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  // Initialize messages as a mutable list
  List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

      // Add the user's input to the messages list
      messages.add({'role': 'user', 'content': prompt});

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        final content = responseData['choices'][0]['message']['content'];
        return content.trim();
      } else {
        print('Error: ${res.statusCode}, ${res.body}');
        return 'Error: Unable to process the request';
      }
    } catch (e, stackTrace) {
      print('Exception: $e\nStackTrace: $stackTrace');
      return 'Error: $e';
    }
  }

  Future<String> DALLEAPI(String prompt) async {
    try {
      final uri = Uri.parse('https://api.openai.com/v1/images/generations');

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPKey',
        },
        body: jsonEncode({
          "prompt": prompt,
          "n": 1,
        }),
      );

      if (res.statusCode == 200) {
        // Extract the image URL
        String imageURL = jsonDecode(res.body)['data'][0]['url'].trim();

        // Add the image URL to messages for continuity
        messages.add({'role': 'assistant', 'content': imageURL});

        return imageURL;
      } else {
        print('Error: ${res.statusCode}, ${res.body}');
        return 'Error: Unable to generate the image';
      }
    } catch (e, stackTrace) {
      print('Exception: $e\nStackTrace: $stackTrace');
      return 'Error: $e';
    }
  }

  Future<String> chatgptAPI(String prompt) async {
    try {
      return await isArtPromptAPI(prompt);
    } catch (e) {
      return 'Error: $e';
    }
  }
}
