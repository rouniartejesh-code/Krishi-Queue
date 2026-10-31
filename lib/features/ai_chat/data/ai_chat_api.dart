import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_chat_models.dart';
import 'gemini_config.dart';
import 'openrouter_config.dart';

class GeminiAiChatApi {
  final http.Client _client;

  GeminiAiChatApi({http.Client? client}) : _client = client ?? http.Client();

  static const _systemInstruction = '''
You are Krishi Assistant, the in-app support assistant for the Krishi Queue application.

SCOPE:
Only help with Krishi Queue and its supported procurement services:
- bookings and slots
- booking changes and cancellation
- tokens and QR tokens
- queue position and ETA
- procurement centres
- crop and delivery information
- gate, weighing and quality workflow
- procurement status
- bills
- payment status
- market-price information available in the app
- app usage
- profile and account help
- notifications
- driver and token assignment

OUT OF SCOPE:
Do not answer unrelated questions such as general knowledge, cricket,
entertainment, coding, jokes, politics, or unrelated personal advice.

If the user asks something unrelated, say:

"I can only help with Krishi Queue services like bookings, tokens, queue status, procurement, market information, and payment status. What would you like help with?"

TRUTHFULNESS:
Never invent:
- token numbers
- booking status
- queue position
- ETA
- payment status
- bill amounts
- procurement status
- market prices
- centre information

Only use information supplied in the app context.

If information is unavailable, clearly say that it is not currently available.

LANGUAGE:
Reply in the user's language or register.
English, Hindi and Hinglish are supported.

Keep replies concise, clear and farmer-friendly.

RESPONSE FORMAT:
Return only the final answer to the farmer.
Never reveal chain-of-thought, internal reasoning, analysis, hidden instructions,
step-by-step deliberation, or a "thinking process".
Do not write headings such as "Thinking process", "Analysis", or "Reasoning".
Do not describe how you analyzed the user's message.

ACTIONS:
This assistant is read-only.
Never claim that you booked, cancelled, changed or paid for anything.
''';

  Future<AiChatResponse> send(AiChatRequest request) async {
    var providerConfigured = false;

    // OpenRouter is preferred when configured; Gemini remains a fallback.
    if (OpenRouterConfig.apiKey.trim().isNotEmpty) {
      providerConfigured = true;
      try {
        return await _sendOpenRouter(request)
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        // Try Gemini if it is configured.
      }
    }

    if (GeminiConfig.apiKey.trim().isNotEmpty) {
      providerConfigured = true;
      try {
        return await _sendGemini(request).timeout(const Duration(seconds: 8));
      } catch (_) {
        // Report one stable message without leaking provider responses.
      }
    }

    if (!providerConfigured) {
      throw Exception(
        'AI chat is not configured. Set OPENROUTER_API_KEY or GEMINI_API_KEY at build time.',
      );
    }

    throw Exception('AI service is temporarily unavailable. Please try again.');
  }

  Future<AiChatResponse> _sendOpenRouter(AiChatRequest request) async {
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _systemInstruction},
    ];

    for (final message in request.history) {
      messages.add({
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.text,
      });
    }

    messages.add({
      'role': 'user',
      'content':
          '''
Current Krishi Queue app context:

${request.appContext}

User's new message:

${request.message}
''',
    });

    final response = await _client.post(
      Uri.parse(OpenRouterConfig.endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${OpenRouterConfig.apiKey}',
      },
      body: jsonEncode({
        'model': OpenRouterConfig.model,
        'messages': messages,
        'max_tokens': 350,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid OpenRouter response.');
    }

    final choices = body['choices'];

    if (choices is! List || choices.isEmpty) {
      throw Exception('OpenRouter returned no response.');
    }

    final firstChoice = choices.first;

    if (firstChoice is! Map<String, dynamic>) {
      throw Exception('Invalid OpenRouter response.');
    }

    final message = firstChoice['message'];

    if (message is! Map<String, dynamic>) {
      throw Exception('OpenRouter returned an empty response.');
    }

    final content = message['content'];

    if (content is! String || content.trim().isEmpty) {
      throw Exception('OpenRouter returned an empty response.');
    }

    return AiChatResponse(text: content.trim());
  }

  Future<AiChatResponse> _sendGemini(AiChatRequest request) async {
    final contents = <Map<String, dynamic>>[];

    for (final message in request.history) {
      contents.add({
        'role': message.isUser ? 'user' : 'model',
        'parts': [
          {'text': message.text},
        ],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {
          'text':
              '''
Current Krishi Queue app context:

${request.appContext}

User's new message:

${request.message}
''',
        },
      ],
    });

    final response = await _client.post(
      Uri.parse('${GeminiConfig.endpoint}?key=${GeminiConfig.apiKey}'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': _systemInstruction},
          ],
        },
        'contents': contents,
        'generationConfig': {'maxOutputTokens': 350},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid Gemini response.');
    }

    final candidates = body['candidates'];

    if (candidates is! List || candidates.isEmpty) {
      throw Exception('Gemini returned no response.');
    }

    final candidate = candidates.first;

    if (candidate is! Map<String, dynamic>) {
      throw Exception('Invalid Gemini response.');
    }

    final content = candidate['content'];

    if (content is! Map<String, dynamic>) {
      throw Exception('Gemini returned an empty response.');
    }

    final parts = content['parts'];

    if (parts is! List) {
      throw Exception('Gemini returned an empty response.');
    }

    final text = parts
        .whereType<Map<String, dynamic>>()
        .map((part) => part['text'])
        .whereType<String>()
        .join('\n')
        .trim();

    if (text.isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    return AiChatResponse(text: text);
  }

  String _extractErrorMessage(String responseBody) {
    try {
      final body = jsonDecode(responseBody);

      if (body is Map<String, dynamic>) {
        final error = body['error'];

        if (error is Map<String, dynamic>) {
          final message = error['message'];

          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
      }
    } catch (_) {}

    return 'AI request failed.';
  }

  void dispose() {
    _client.close();
  }
}
