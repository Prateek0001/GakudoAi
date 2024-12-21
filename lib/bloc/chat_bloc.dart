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
  Map<String, List<ChatMessage>> conversations = {};
  String currentConversationId = '';
  int conversationCounter = 1;

  ChatBloc(this.prefs, this.chatRepository) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<NewChatEvent>(_onNewChat);
    on<LoadConversationEvent>(_onLoadConversation);
    on<DeleteConversationEvent>(_onDeleteConversation);

    // Create initial conversation and emit initial state
    _createNewConversation();
    emit(ChatLoaded(
      messages: messages,
      conversations: conversations,
    ));
  }

  void _createNewConversation() {
    currentConversationId = 'Conversation $conversationCounter';
    messages = [];
    conversations[currentConversationId] = messages;
    conversationCounter++;
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
      conversations[currentConversationId] = messages;

      emit(ChatLoaded(
        messages: messages,
        isTyping: true,
        conversations: conversations,
      ));

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
        conversations[currentConversationId] = messages;

        emit(ChatLoaded(
          messages: messages,
          conversations: conversations,
        ));
      } catch (e) {
        emit(ChatLoaded(
          messages: messages,
          conversations: conversations,
        ));
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
    emit(ChatLoaded(
      messages: messages,
      conversations: conversations,
    ));
  }

  void _onNewChat(NewChatEvent event, Emitter<ChatState> emit) {
    _createNewConversation();
    emit(ChatLoaded(
      messages: messages,
      conversations: conversations,
    ));
  }

  Future<void> _onDeleteConversation(
    DeleteConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    conversations.remove(event.conversationId);

    // If current conversation is deleted, create a new one
    if (event.conversationId == currentConversationId) {
      _createNewConversation();
    }

    emit(ChatLoaded(
      messages: messages,
      conversations: conversations,
    ));
  }

  Future<void> _onLoadConversation(
    LoadConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    currentConversationId = event.conversationId;
    messages = conversations[event.conversationId] ?? [];
    emit(ChatLoaded(
      messages: messages,
      conversations: conversations,
    ));
  }
}
