// lib/features/chat/data/datasources/chat_remote_datasource.dart

import 'package:caller_host_app/core/services/api_client.dart';
import 'package:caller_host_app/features/chat/data/models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatConversationModel>> fetchConversations();

  Future<List<MessageModel>> fetchMessages({required String otherUserId});

  Future<MessageModel> sendMessage({
    required String recipientId,
    required String text,
  });

  Future<void> markAsRead({required String messageId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ChatConversationModel>> fetchConversations() async {
    try {
      final response = await apiClient.get('/api/chat/conversations');

      if (response.statusCode == 200) {
        final data = response.body;
        
        List<dynamic> conversations = data is List
            ? data
            : (data is Map && data['conversations'] != null
                ? data['conversations']
                : []);

        return conversations
            .map((c) =>
                ChatConversationModel.fromJson(c as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch conversations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching conversations: $e');
    }
  }

  @override
  Future<List<MessageModel>> fetchMessages({required String otherUserId}) async {
    try {
      final response =
          await apiClient.get('/api/chat/messages/$otherUserId');

      if (response.statusCode == 200) {
        final data = response.body;
        
        List<dynamic> messages = data is List
            ? data
            : (data is Map && data['messages'] != null
                ? data['messages']
                : []);

        return messages
            .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String recipientId,
    required String text,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/chat/messages',
        body: {
          'recipientId': recipientId,
          'text': text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body;
        return MessageModel.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  @override
  Future<void> markAsRead({required String messageId}) async {
    try {
      final response = await apiClient.put(
        '/api/chat/messages/$messageId/read',
        body: {'read': true},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark message as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking as read: $e');
    }
  }
}
