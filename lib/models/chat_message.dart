// lib/models/chat_message.dart

class ChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final bool isTyping; // Untuk menampilkan indikator loading
  final bool isError; // Untuk menandai pesan error

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    this.isTyping = false,
    this.isError = false,
  });
}
