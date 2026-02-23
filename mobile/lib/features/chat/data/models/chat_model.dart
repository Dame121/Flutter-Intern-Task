// lib/features/chat/data/models/chat_model.dart

import 'package:caller_host_app/features/chat/domain/entities/chat_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required String id,
    required String senderId,
    required String recipientId,
    required String text,
    required DateTime createdAt,
    required String state,
    double? cost,
  }) : super(
    id: id,
    senderId: senderId,
    recipientId: recipientId,
    text: text,
    createdAt: createdAt,
    state: state,
    cost: cost,
  );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      text: json['text'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      state: json['state'] ?? 'sent',
      cost: (json['cost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'state': state,
      'cost': cost,
    };
  }
}

class ChatConversationModel extends ChatConversationEntity {
  const ChatConversationModel({
    required String userId,
    required String otherUserId,
    MessageEntity? lastMessage,
    required DateTime updatedAt,
  }) : super(
    userId: userId,
    otherUserId: otherUserId,
    lastMessage: lastMessage,
    updatedAt: updatedAt,
  );

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      userId: json['userId'] ?? '',
      otherUserId: json['otherUserId'] ?? '',
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'otherUserId': otherUserId,
      'lastMessage': lastMessage != null
          ? (lastMessage as MessageModel).toJson()
          : null,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
