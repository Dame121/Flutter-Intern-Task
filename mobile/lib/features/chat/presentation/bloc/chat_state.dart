// lib/features/chat/presentation/bloc/chat_state.dart

import 'package:equatable/equatable.dart';
import 'package:caller_host_app/features/chat/domain/entities/chat_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitialState extends ChatState {
  const ChatInitialState();
}

class ChatLoadingState extends ChatState {
  const ChatLoadingState();
}

class ChatConversationsLoadedState extends ChatState {
  final List<ChatConversationEntity> conversations;

  const ChatConversationsLoadedState({required this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class ChatMessagesLoadedState extends ChatState {
  final List<MessageEntity> messages;
  final String otherUserId;

  const ChatMessagesLoadedState({
    required this.messages,
    required this.otherUserId,
  });

  @override
  List<Object?> get props => [messages, otherUserId];
}

class ChatMessageSentState extends ChatState {
  final MessageEntity message;

  const ChatMessageSentState({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatErrorState extends ChatState {
  final String message;

  const ChatErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatEmptyState extends ChatState {
  const ChatEmptyState();
}
