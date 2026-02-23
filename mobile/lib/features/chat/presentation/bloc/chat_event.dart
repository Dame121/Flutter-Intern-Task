// lib/features/chat/presentation/bloc/chat_event.dart

import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String recipientId;
  final String messageText;

  const SendMessageEvent({
    required this.recipientId,
    required this.messageText,
  });

  @override
  List<Object?> get props => [recipientId, messageText];
}

class LoadMessagesEvent extends ChatEvent {
  final String otherUserId;

  const LoadMessagesEvent({required this.otherUserId});

  @override
  List<Object?> get props => [otherUserId];
}

class LoadConversationsEvent extends ChatEvent {
  const LoadConversationsEvent();
}

class MarkAsReadEvent extends ChatEvent {
  final String messageId;

  const MarkAsReadEvent({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class RefreshMessagesEvent extends ChatEvent {
  final String otherUserId;

  const RefreshMessagesEvent({required this.otherUserId});

  @override
  List<Object?> get props => [otherUserId];
}
