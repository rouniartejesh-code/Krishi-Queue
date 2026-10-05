import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_repository.dart';
import '../../booking/domain/booking_status.dart';
import '../../market/data/market_price_repository.dart';
import '../../procurement/domain/procurement_status.dart';
import '../data/ai_chat_api.dart';
import '../data/ai_chat_models.dart';
import '../domain/chat_message.dart';
import 'widgets/chat_input.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_suggestion_chip.dart';
import 'widgets/typing_indicator.dart';

class AiChatScreen extends StatefulWidget {
  final BookingRepository bookingRepository;
  final MarketPriceRepository marketPriceRepository;
  final GeminiAiChatApi api;

  const AiChatScreen({
    super.key,
    required this.bookingRepository,
    required this.marketPriceRepository,
    required this.api,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _sending = false;

  // Used to change the quick actions based on the latest topic.
  String _suggestionContext = '';

  static const _welcomeSuggestions = [
    ('Book a slot', Icons.event_available_outlined),
    ('Check my token', Icons.qr_code_2_rounded),
    ('Check queue / ETA', Icons.track_changes_outlined),
    ('Payment status', Icons.account_balance_wallet_outlined),
    ("Today's market price", Icons.currency_rupee_rounded),
    ('My bookings', Icons.calendar_month_outlined),
  ];

  @override
  void initState() {
    super.initState();

    _messages.add(
      ChatMessage(
        role: ChatMessageRole.assistant,
        text:
            'Namaste! I’m Krishi Assistant. I can help with bookings, tokens, queue status, procurement, market prices, and payment status.',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _buildAppContext(String userMessage) async {
    final booking = await widget.bookingRepository.getBooking();

    final buffer = StringBuffer();

    _appendBookingContext(buffer, booking);

    // Market data is fetched only for market-price questions.
    // Normal ChatBox messages must never wait for data.gov.in.
    final query = userMessage.toLowerCase();
    final needsMarketData =
        query.contains('price') ||
        query.contains('market') ||
        query.contains('rate') ||
        query.contains('mandi') ||
        query.contains('भाव') ||
        query.contains('दाम') ||
        query.contains('कीमत');

    if (!needsMarketData) {
      return buffer.toString();
    }

    try {
      final prices = await widget.marketPriceRepository.getMarketPrices();

      buffer.writeln('\nAvailable market-price records in this app:');

      for (final price in prices) {
        buffer.writeln(
          '- ${price.commodity} (${price.variety}), ${price.market}: '
          '₹${price.minPrice}-₹${price.maxPrice}/QTL, '
          'modal ₹${price.modalPrice}/QTL, '
          'grade ${price.grade}, '
          'date ${price.observationDate.toIso8601String().split('T').first}',
        );
      }
    } catch (_) {
      buffer.writeln(
        '\nMarket-price data is currently unavailable. '
        'Do not invent market prices.',
      );
    }

    return buffer.toString();
  }

  void _appendBookingContext(
    StringBuffer buffer,
    Booking booking,
  ) {
    buffer.writeln('Current booking data (local demo/app data):');
    buffer.writeln('- Booking number: ${booking.bookingNumber}');
    buffer.writeln('- Booking status: ${booking.status.label}');
    buffer.writeln('- Token: ${booking.token}');
    buffer.writeln('- Queue position: ${booking.queuePosition}');
    buffer.writeln(
      '- Estimated wait: ${booking.estimatedWaitMinutes} minutes',
    );
    buffer.writeln('- Centre: ${booking.queueState.centre}');
    buffer.writeln('- Crop: ${booking.queueState.crop}');
    buffer.writeln('- Quantity: ${booking.quantityQtl} QTL');
    buffer.writeln('- Slot: ${booking.queueState.slot}');
    buffer.writeln('- Delivery date: ${booking.deliveryDate}');
    buffer.writeln(
      '- Procurement status: ${booking.procurement.status.label}',
    );
    buffer.writeln(
      '- Bill amount: ${booking.procurement.billAmount ?? 'not available'}',
    );
    buffer.writeln(
      '- Payment reference: '
      '${booking.procurement.paymentReference ?? 'not available'}',
    );
    buffer.writeln('- Driver assigned: ${booking.driverAssigned}');
    buffer.writeln('- Driver arrived: ${booking.driverArrived}');
  }

  Future<void> _sendMessage(String text) async {
    if (_sending) return;

    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          role: ChatMessageRole.user,
          text: cleanText,
          timestamp: DateTime.now(),
        ),
      );

      _sending = true;
    });

    _scrollToBottom();

    try {
      final appContext = await _buildAppContext(cleanText);

      final response = await widget.api.send(
        AiChatRequest(
          history: List.unmodifiable(
            _messages.take(_messages.length - 1),
          ),
          message: cleanText,
          appContext: appContext,
        ),
      );

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            role: ChatMessageRole.assistant,
            text: response.text,
            timestamp: DateTime.now(),
          ),
        );

        // Change quick actions according to the user's latest topic.
        _suggestionContext = cleanText;

        _sending = false;
      });
    } catch (error) {
      if (!mounted) return;

      final message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .trim();

      setState(() {
        _messages.add(
          ChatMessage(
            role: ChatMessageRole.assistant,
            text:
                'Sorry, I could not connect right now. Please try again.\n\n$message',
            timestamp: DateTime.now(),
          ),
        );

        _sending = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  List<(String, IconData)> _contextSuggestions(String text) {
    final q = text.toLowerCase();

    if (q.contains('token') || q.contains('qr')) {
      return const [
        ('Show my QR token', Icons.qr_code_2_rounded),
        ('Track my queue', Icons.track_changes_outlined),
        ('Show booking details', Icons.receipt_long_outlined),
      ];
    }

    if (q.contains('queue') ||
        q.contains('eta') ||
        q.contains('wait')) {
      return const [
        ('Check my queue position', Icons.track_changes_outlined),
        ('Check estimated wait', Icons.schedule_outlined),
        ('Show my token', Icons.qr_code_2_rounded),
      ];
    }

    if (q.contains('book') || q.contains('slot')) {
      return const [
        ('Show available slots', Icons.event_available_outlined),
        ('Show my bookings', Icons.calendar_month_outlined),
        ('How do I cancel a booking?', Icons.cancel_outlined),
      ];
    }

    if (q.contains('payment') ||
        q.contains('paid') ||
        q.contains('money')) {
      return const [
        (
          'Check payment status',
          Icons.account_balance_wallet_outlined,
        ),
        ('Show my bill details', Icons.receipt_long_outlined),
        ('When will my payment arrive?', Icons.payments_outlined),
      ];
    }

    if (q.contains('price') ||
        q.contains('market') ||
        q.contains('rate')) {
      return const [
        (
          "Today's market prices",
          Icons.currency_rupee_rounded,
        ),
        (
          'How are market prices updated?',
          Icons.trending_up_rounded,
        ),
        (
          'Show procurement information',
          Icons.agriculture_outlined,
        ),
      ];
    }

    if (q.contains('procurement') ||
        q.contains('crop') ||
        q.contains('weigh')) {
      return const [
        (
          'What is the weighing process?',
          Icons.scale_outlined,
        ),
        (
          'Check procurement status',
          Icons.agriculture_outlined,
        ),
        (
          'Show my booking',
          Icons.receipt_long_outlined,
        ),
      ];
    }

    return _welcomeSuggestions;
  }

  String _suggestionTitle(String text) {
    final q = text.toLowerCase();

    if (q.contains('token') || q.contains('qr')) {
      return 'Token help';
    }

    if (q.contains('queue') ||
        q.contains('eta') ||
        q.contains('wait')) {
      return 'Queue help';
    }

    if (q.contains('book') || q.contains('slot')) {
      return 'Booking help';
    }

    if (q.contains('payment') ||
        q.contains('paid') ||
        q.contains('money')) {
      return 'Payment help';
    }

    if (q.contains('price') ||
        q.contains('market') ||
        q.contains('rate')) {
      return 'Market help';
    }

    if (q.contains('procurement') ||
        q.contains('crop') ||
        q.contains('weigh')) {
      return 'Procurement help';
    }

    return 'Quick help';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Krishi Assistant',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Online support',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                12,
              ),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_sending && index == _messages.length) {
                  return const TypingIndicator();
                }

                return ChatMessageBubble(
                  message: _messages[index],
                );
              },
            ),
          ),

          // Quick actions stay available while the assistant is idle.
          if (!_sending && _messages.isNotEmpty)
            _buildSuggestions(),

          ChatInput(
            enabled: !_sending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final isWelcome = _suggestionContext.isEmpty;

    final suggestions = isWelcome
        ? _welcomeSuggestions
        : _contextSuggestions(_suggestionContext);

    final title = isWelcome
        ? 'What can I help you with?'
        : _suggestionTitle(_suggestionContext);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
              bottom: 7,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 1,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, _) {
                return const SizedBox(width: 7);
              },
              itemBuilder: (_, index) {
                final suggestion = suggestions[index];

                return ChatSuggestionChip(
                  label: suggestion.$1,
                  icon: suggestion.$2,
                  onTap: () => _sendMessage(
                    suggestion.$1,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}