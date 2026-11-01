import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/settings/app_preferences.dart';

class ChatInput extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onSend;

  const ChatInput({super.key, required this.enabled, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (!widget.enabled || text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 7, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => _send(),
                maxLength: 1000,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: AppPreferences.of(context)
                      .text('Type your question…', 'अपना सवाल लिखें…'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: AppPreferences.of(context)
                  .text('Send question', 'सवाल भेजें'),
              onPressed: widget.enabled ? _send : null,
              style: IconButton.styleFrom(
                minimumSize: const Size(52, 52),
                backgroundColor: AppTheme.primaryGreen,
              ),
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
