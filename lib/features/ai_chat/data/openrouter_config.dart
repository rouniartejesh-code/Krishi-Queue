class OpenRouterConfig {
  const OpenRouterConfig._();

  static const apiKey = String.fromEnvironment('OPENROUTER_API_KEY');
  static const model = 'openrouter/free';
  static const endpoint = 'https://openrouter.ai/api/v1/chat/completions';
}
