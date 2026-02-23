// lib/features/chat/domain/repositories/chat_repository.dart

import 'package:caller_host_app/features/chat/domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Future<List<ChatConversationEntity>> getConversations();

  Future<List<MessageEntity>> loadMessages({required String otherUserId});

  Future<MessageEntity> sendMessage({
    required String recipientId,
    required String text,
  });

  Future<void> markAsRead({required String messageId});
}
