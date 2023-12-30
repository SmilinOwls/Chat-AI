import 'dart:convert';
import 'dart:io';
import 'package:chat_ai_app/models/chat/message.dart';
import 'package:http/http.dart' as http;

class ChatService {
  static String chatKey = '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';

  void askAI({
    required List<Message> messages,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final List<Map<String, String>> messagesData = messages
        .map((message) => {
              'role': message.isUser ? 'user' : 'assistant',
              'content': message.text,
            })
        .toList();
    try {
      var response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $chatKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messagesData,
          'max_tokens': 3000,
        }),
      );

      if (response.statusCode != 200) {
        throw const HttpException('Failed to get response from AI');
      }

      final responseData = jsonDecode(response.body);
      String aiResponse = responseData['choices'][0]['message']['content'];

      await onSuccess(aiResponse);
    } on HttpException catch (e) {
      onError(e.message);
    }
  }
}
