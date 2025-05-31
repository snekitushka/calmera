import 'package:calmera/services/user_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class ChatService {
  static Future<String> sendMessage(String userMessage) async {
    final response = await ApiClient.post('chatbot/message', {
      'content': userMessage,
    });
    return response.data['message'] ?? 'Нет ответа от бота';
  }

  static Future<List<Map<String, dynamic>>> getConversation() async {
    final response = await ApiClient.get('chatbot/conversation');
    final List messages = response.data['messages'];
    return messages.reversed.map<Map<String, dynamic>>((msg) {
      return {
        'text': msg['content'],
        'isUser': msg['message_type'] == 'user',
      };
    }).toList();
  }
}
