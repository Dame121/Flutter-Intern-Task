// lib/features/chat/data/repositories/chat_repository_impl.dart

import 'package:caller_host_app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:caller_host_app/features/chat/domain/entities/chat_entity.dart';
import 'package:caller_host_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatConversationEntity>> getConversations() async {
    return await remoteDataSource.fetchConversations();
  }

  @override
  Future<List<MessageEntity>> loadMessages({required String otherUserId}) async {
    return await remoteDataSource.fetchMessages(otherUserId: otherUserId);
  }

  @override
  Future<MessageEntity> sendMessage({
    required String recipientId,
    required String text,
  }) async {
    return await remoteDataSource.sendMessage(
      recipientId: recipientId,
      text: text,
    );
  }

  @override
  Future<void> markAsRead({required String messageId}) async {
    await remoteDataSource.markAsRead(messageId: messageId);
  }
}
