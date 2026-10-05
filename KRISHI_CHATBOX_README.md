# Krishi Queue AI ChatBox

Implemented:

- Bottom navigation: Home | Chat | Bookings
- Swiggy/Zomato-style support chat UI
- Gemini-powered responses
- English / Hindi / Hinglish support
- Krishi Queue-only response scope
- Quick actions for booking, token, queue/ETA, payment, and market price
- Typing indicator, loading state, and API error handling
- Current local booking and market-price data supplied as verified app context

## Gemini

Uses the stable `gemini-3.8-flash` model through Google's Gemini `generateContent` API.

The supplied API key is included in `lib/features/ai_chat/data/gemini_config.dart` so the prototype can run immediately.

**Production note:** a Flutter app cannot keep a Gemini API key secret from a determined user. Before production deployment, move the Gemini call behind a server/Firebase Cloud Function and rotate the currently exposed key.
