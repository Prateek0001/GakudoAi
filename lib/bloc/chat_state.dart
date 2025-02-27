import 'package:equatable/equatable.dart';
import '../models/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final Map<String, List<ChatMessage>> conversations;

  const ChatLoaded({
    required this.messages,
    this.isTyping = false,
    this.conversations = const {},
  });

  @override
  List<Object> get props => [messages, isTyping, conversations];

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
