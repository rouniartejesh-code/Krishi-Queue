# Krishi Queue AI Chat

The chat UI supports English, Hindi, and Hinglish. It supplies the assistant with the current local demo booking and requests market data only when the message asks about prices. Replies are intended to stay within Krishi Queue support topics and remain read-only.

Configure `OPENROUTER_API_KEY` and/or `GEMINI_API_KEY` with `--dart-define` when building or running the app. OpenRouter is tried first, followed by Gemini. If neither key is configured, the chat reports that configuration is missing instead of making doomed requests.

Client-side API keys can be extracted from a distributed app even when passed through `--dart-define`. Use a server or Firebase Cloud Function for production requests, and rotate any API keys that were previously committed to this repository.
