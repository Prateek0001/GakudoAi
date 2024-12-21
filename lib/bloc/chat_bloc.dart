import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../repositories/chat/chat_repository.dart';
import '../constants/storage_constants.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SharedPreferences prefs;
  final ChatRepository chatRepository;
  List<ChatMessage> messages = [];
  List<ChatMessage> allMessages = [];

  ChatBloc(this.prefs, this.chatRepository) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<NewChatEvent>(_onNewChat);
    on<LoadConversationEvent>(_onLoadConversation);

    add(LoadChatHistoryEvent());
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Add user message
      final userMessage = ChatMessage(
        content: event.message,
        role: MessageRole.user,
      );
      messages = [...messages, userMessage];
      allMessages = [...allMessages, userMessage];
      emit(ChatLoaded(messages: messages, isTyping: true));

      // Get token and username from SharedPreferences
      final token = prefs.getString(StorageConstants.authToken);
      final userProfileJson = prefs.getString(StorageConstants.userProfile);
      if (token == null || userProfileJson == null) {
        throw Exception('User not authenticated');
      }
      final userProfile = UserProfile.fromJson(jsonDecode(userProfileJson));

      try {
        // Get AI response from API
        final response = await chatRepository.sendMessage(
          question: event.message,
          username: userProfile.username,
          token: token,
        );

        // Add AI response
        final aiMessage = ChatMessage(
          content: response,
          role: MessageRole.assistant,
        );
        messages = [...messages, aiMessage];
        allMessages = [...allMessages, aiMessage];

        // Save to local storage before emitting new state
        await _saveChatHistory();

        emit(ChatLoaded(messages: messages));
      } catch (e) {
        // If API call fails, show error but keep user message
        emit(ChatLoaded(messages: messages));
        emit(ChatError('Failed to get response: ${e.toString()}'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      final chatHistory = prefs.getStringList(StorageConstants.chatHistory);
      if (chatHistory != null) {
        allMessages = chatHistory
            .map((msg) => ChatMessage.fromMap(json.decode(msg)))
            .toList();
        messages = allMessages;
      }
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onNewChat(NewChatEvent event, Emitter<ChatState> emit) {
    messages = [];
    emit(ChatLoaded(messages: messages));
  }

  void _onLoadConversation(
    LoadConversationEvent event,
    Emitter<ChatState> emit,
  ) {
    final conversation = allMessages.where((message) {
      final timeDiff = message.timestamp
          .difference(allMessages
              .firstWhere((m) => m.id == event.conversationId)
              .timestamp)
          .inMinutes
          .abs();
      return timeDiff <= 30;
    }).toList();

    messages = conversation;
    emit(ChatLoaded(messages: messages));
  }

  Future<void> _saveChatHistory() async {
    final chatHistory =
        allMessages.map((msg) => json.encode(msg.toMap())).toList();
    await prefs.setStringList(StorageConstants.chatHistory, chatHistory);
  }
}
