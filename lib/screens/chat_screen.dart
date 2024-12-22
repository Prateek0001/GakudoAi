import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../constants/app_constants.dart';
import '../constants/string_constants.dart';
import '../models/chat_message.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatBloc = context.read<ChatBloc>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          StringConstants.aiChat,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
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
      backgroundColor: Colors.white,
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatLoaded) {
            final conversations = state.conversations;

            return Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Conversations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<ChatBloc>().add(NewChatEvent());
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${conversations.length} ${conversations.length == 1 ? 'conversation' : 'conversations'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (conversations.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a new chat to begin',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: conversations.entries.length,
                      itemBuilder: (context, index) {
                        final entry = conversations.entries.elementAt(index);
                        final messages = entry.value;
                        if (messages.isEmpty) return const SizedBox.shrink();

                        final firstMessage = messages.first;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Dismissible(
                            key: Key(entry.key),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade700,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              context.read<ChatBloc>().add(
                                    DeleteConversationEvent(entry.key),
                                  );
                            },
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  context
                                      .read<ChatBloc>()
                                      .add(LoadConversationEvent(entry.key));
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.chat_outlined,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.key,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              firstMessage.content,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.grey[400],
                                        ),
                                        onPressed: () {
                                          context.read<ChatBloc>().add(
                                                DeleteConversationEvent(
                                                    entry.key),
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
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
  final _speechToText = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _messageController.text = result.recognizedWords;
        });
      },
    );
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;
    context.read<ChatBloc>().add(SendMessageEvent(message));
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatLoaded) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ChatBubble(
                          message: message.content,
                          isUser: message.role == MessageRole.user,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (state.isTyping)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI is typing...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          suffixIcon: IconButton(
                            onPressed:
                                _speechToText.isAvailable && !_isListening
                                    ? _startListening
                                    : _stopListening,
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(_messageController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speechToText.cancel();
    super.dispose();
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: EdgeInsets.only(
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: MarkdownBody(
          data: message,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
