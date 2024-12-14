import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../constants/app_constants.dart';
import '../constants/string_constants.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatBloc = context.read<ChatBloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.aiChat),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              chatBloc.add(NewChatEvent());
            },
          ),
        ],
      ),
      drawer: const ChatHistoryDrawer(),
      body: BlocProvider.value(
        value: chatBloc,
        child: const ChatView(),
      ),
    );
  }
}

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatLoaded) {
            final conversations = _groupConversations(state.messages);

            return ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringConstants.chatHistory,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppConstants.headingMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                if (conversations.isEmpty)
                  ListTile(
                    title: Text(StringConstants.noChatMessages),
                  ),
                ...conversations.entries.map((entry) {
                  final firstMessage = entry.value.first;
                  return ListTile(
                    leading: const Icon(Icons.chat),
                    title: Text(
                      firstMessage.content.length > 30
                          ? '${firstMessage.content.substring(0, 30)}...'
                          : firstMessage.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatDate(firstMessage.timestamp),
                      style: TextStyle(fontSize: AppConstants.bodySmall),
                    ),
                    onTap: () {
                      context.read<ChatBloc>().add(LoadConversationEvent(entry.key));
                      Navigator.pop(context);
                    },
                  );
                }),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(StringConstants.newChat),
                  onTap: () {
                    context.read<ChatBloc>().add(NewChatEvent());
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }

          return Center(child: Text(StringConstants.noChatHistory));
        },
      ),
    );
  }

  Map<String, List<ChatMessage>> _groupConversations(List<ChatMessage> messages) {
    final conversations = <String, List<ChatMessage>>{};
    String currentConversationId = '';
    List<ChatMessage> currentConversation = [];

    for (final message in messages) {
      if (currentConversation.isEmpty) {
        currentConversationId = message.id;
        currentConversation = [message];
      } else if (_isPartOfSameConversation(currentConversation.last, message)) {
        currentConversation.add(message);
      } else {
        conversations[currentConversationId] = List.from(currentConversation);
        currentConversationId = message.id;
        currentConversation = [message];
      }
    }

    if (currentConversation.isNotEmpty) {
      conversations[currentConversationId] = List.from(currentConversation);
    }

    return conversations;
  }

  bool _isPartOfSameConversation(ChatMessage last, ChatMessage current) {
    return current.timestamp.difference(last.timestamp).inMinutes.abs() <= 30;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${StringConstants.today} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '${StringConstants.yesterday} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded && state.messages.isNotEmpty) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatError) {
          return Center(child: Text('${StringConstants.error}: ${state.message}'));
        }

        if (state is ChatLoaded) {
          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? Center(child: Text(StringConstants.startNewChat))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(AppConstants.spacingM),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          return _MessageBubble(message: message);
                        },
                      ),
              ),
              if (state.isTyping)
                Padding(
                  padding: EdgeInsets.all(AppConstants.spacingM),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(StringConstants.aiIsTyping),
                      SizedBox(width: AppConstants.spacingXS),
                      SizedBox(
                        width: AppConstants.iconS,
                        height: AppConstants.iconS,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ),
                ),
              _buildMessageInput(),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacingXS),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: StringConstants.messageHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          SizedBox(width: AppConstants.spacingXS),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_messageController.text),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;
    context.read<ChatBloc>().add(SendMessageEvent(message));
    _messageController.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: AppConstants.maxMessageWidth,
        ),
        margin: EdgeInsets.symmetric(vertical: AppConstants.spacingXXS),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingXS,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.chatBubbleRadius),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
