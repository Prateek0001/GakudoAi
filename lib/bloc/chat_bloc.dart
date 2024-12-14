import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SharedPreferences prefs;
  List<ChatMessage> messages = [];
  List<ChatMessage> allMessages = [];

  ChatBloc(this.prefs) : super(ChatInitial()) {
    OpenAI.apiKey = AppConstants.openAiKey;

    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<NewChatEvent>(_onNewChat);
    on<LoadConversationEvent>(_onLoadConversation);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ChatLoaded) {
        // Add user message
        final userMessage = ChatMessage(
          content: event.message,
          role: MessageRole.user,
        );
        messages = [...messages, userMessage];
        emit(ChatLoaded(messages: messages, isTyping: true));

        // Get AI response
        final response = await OpenAI.instance.chat.create(
          model: AppConstants.openAiModel,
          messages: messages
              .map((msg) => OpenAIChatCompletionChoiceMessageModel(
                    content: [
                      OpenAIChatCompletionChoiceMessageContentItemModel.text(
                          msg.content)
                    ],
                    role: msg.role == MessageRole.user
                        ? OpenAIChatMessageRole.user
                        : OpenAIChatMessageRole.assistant,
                  ))
              .toList(),
        );

        if (response.choices.isNotEmpty) {
          // Add AI response
          final aiMessage = ChatMessage(
            content: response.choices.first.message.content.toString(),
            role: MessageRole.assistant,
          );
          messages = [...messages, aiMessage];
          emit(ChatLoaded(messages: messages));

          // Save to local storage
          _saveChatHistory();
        }
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
      final chatHistory = prefs.getStringList('chat_history');
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
    await prefs.setStringList('chat_history', chatHistory);
  }
}
