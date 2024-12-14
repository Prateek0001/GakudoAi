import 'package:equatable/equatable.dart';


abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class LoadChatHistoryEvent extends ChatEvent {}

class NewChatEvent extends ChatEvent {}

class LoadConversationEvent extends ChatEvent {
  final String conversationId;

  const LoadConversationEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
} 