// lib/features/chat/domain/entities/chat_entity.dart

import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime createdAt;
  final String state; // sent, delivered, read
  final double cost;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.createdAt,
    required this.state,
    required this.cost,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    recipientId,
    text,
    createdAt,
    state,
    cost,
  ];
}

class ChatConversationEntity extends Equatable {
  final String id;
  final String userId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final MessageEntity? lastMessage;
  final DateTime updatedAt;

  const ChatConversationEntity({
    required this.id,
    required this.userId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    this.lastMessage,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    otherUserId,
    otherUserName,
    otherUserPhotoUrl,
    lastMessage,
    updatedAt,
  ];
}
