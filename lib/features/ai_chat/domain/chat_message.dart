enum ChatMessageRole { user, assistant }

class ChatMessage {
  final ChatMessageRole role;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  bool get isUser => role == ChatMessageRole.user;
}
