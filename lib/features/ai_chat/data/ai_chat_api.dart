import '../../../core/network/krishi_gateway.dart';
import 'ai_chat_models.dart';

/// Provider keys stay on the authenticated backend. No booking or bank context
/// is sent to the online model; the farmer explicitly sends one question.
class GeminiAiChatApi {
  GeminiAiChatApi({KrishiGateway? gateway})
    : _gateway = gateway ?? KrishiGateway();
  final KrishiGateway _gateway;
  bool get configured => _gateway.configured;

  Future<AiChatResponse> send(AiChatRequest request) async {
    final result = await _gateway.post('assistant', {
      'message': request.message,
      'language': RegExp(r'[\u0900-\u097F]').hasMatch(request.message)
          ? 'hi'
          : 'en',
    });
    final text = result['text'];
    if (text is! String || text.trim().isEmpty) {
      throw const GatewayException(
        'No answer was received. Please use the saved guidance.',
      );
    }
    return AiChatResponse(text: text.trim());
  }

  Future<String> translate(
    String text, {
    required String source,
    required String target,
  }) async {
    final result = await _gateway.post('translate', {
      'text': text,
      'source': source,
      'target': target,
    });
    final translated = result['text'];
    if (translated is! String || translated.trim().isEmpty) {
      throw const GatewayException(
        'Translation is unavailable. The original text is kept.',
      );
    }
    return translated.trim();
  }

  void dispose() => _gateway.dispose();
}
