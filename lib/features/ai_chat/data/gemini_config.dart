class GeminiConfig {
  const GeminiConfig._();

  static const apiKey = '';
  static const model = 'gemini-3.5-flash-lite';
  static const endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
}