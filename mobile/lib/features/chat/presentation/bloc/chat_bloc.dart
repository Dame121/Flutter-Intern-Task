// lib/features/chat/presentation/bloc/chat_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:caller_host_app/features/chat/domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc({required this.repository}) : super(const ChatInitialState()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<RefreshMessagesEvent>(_onRefreshMessages);
    on<MarkAsReadEvent>(_onMarkAsRead);
  }

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoadingState());
    try {
      final conversations = await repository.getConversations();
      if (conversations.isEmpty) {
        emit(const ChatEmptyState());
      } else {
        emit(ChatConversationsLoadedState(conversations: conversations));
      }
    } catch (e) {
      emit(ChatErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoadingState());
    try {
      final messages =
          await repository.loadMessages(otherUserId: event.otherUserId);
      if (messages.isEmpty) {
        emit(const ChatEmptyState());
      } else {
        emit(ChatMessagesLoadedState(
          messages: messages,
          otherUserId: event.otherUserId,
        ));
      }
    } catch (e) {
      emit(ChatErrorState(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final message = await repository.sendMessage(
        recipientId: event.recipientId,
        text: event.messageText,
      );
      emit(ChatMessageSentState(message: message));

      // Refresh messages after sending
      add(LoadMessagesEvent(otherUserId: event.recipientId));
    } catch (e) {
      emit(ChatErrorState(message: e.toString()));
    }
  }

  Future<void> _onRefreshMessages(
    RefreshMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messages =
          await repository.loadMessages(otherUserId: event.otherUserId);
      if (messages.isEmpty) {
        emit(const ChatEmptyState());
      } else {
        emit(ChatMessagesLoadedState(
          messages: messages,
          otherUserId: event.otherUserId,
        ));
      }
    } catch (e) {
      emit(ChatErrorState(message: e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await repository.markAsRead(messageId: event.messageId);
    } catch (e) {
      // Don't emit error for mark as read, just log silently
      print('Error marking message as read: $e');
    }
  }
}
