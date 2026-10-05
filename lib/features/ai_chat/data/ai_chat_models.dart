import '../domain/chat_message.dart';

class AiChatRequest {
  final List<ChatMessage> history;
  final String message;
  final String appContext;

  const AiChatRequest({
    required this.history,
    required this.message,
    required this.appContext,
  });
}

class AiChatResponse {
  final String text;

  const AiChatResponse({required this.text});
}
