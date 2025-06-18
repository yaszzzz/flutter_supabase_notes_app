// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_bar.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;

    final userMessageText = _textController.text;
    _textController.clear();
    FocusScope.of(context).unfocus(); // Tutup keyboard

    setState(() {
      _isLoading = true;
      // Tambahkan pesan pengguna
      _messages.add(
        ChatMessage(id: _uuid.v4(), text: userMessageText, isFromUser: true),
      );
      _scrollDown();
      // Tambahkan indikator 'typing' dari AI
      _messages.add(
        ChatMessage(
          id: _uuid.v4(),
          text: '...',
          isFromUser: false,
          isTyping: true,
        ),
      );
      _scrollDown();
    });

    try {
      final responseText = await _geminiService.sendMessage(userMessageText);
      setState(() {
        // Hapus indikator 'typing'
        _messages.removeWhere((msg) => msg.isTyping);
        // Tambahkan respons AI
        _messages.add(
          ChatMessage(id: _uuid.v4(), text: responseText, isFromUser: false),
        );
      });
    } catch (e) {
      setState(() {
        // Hapus indikator 'typing'
        _messages.removeWhere((msg) => msg.isTyping);
        // Tambahkan pesan error
        _messages.add(
          ChatMessage(
            id: _uuid.v4(),
            text: 'Maaf, terjadi kesalahan. Coba lagi.',
            isFromUser: false,
            isError: true,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Clean Arch')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          MessageInputBar(
            controller: _textController,
            isLoading: _isLoading,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
