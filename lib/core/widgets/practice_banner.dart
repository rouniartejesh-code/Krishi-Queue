import 'package:flutter/material.dart';

import '../settings/app_preferences.dart';

class PracticeBanner extends StatelessWidget {
  const PracticeBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final p = AppPreferences.of(context);
    return Material(
      color: const Color(0xffffedce),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 20, color: Color(0xff654311)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                p.text(
                  'Practice only · Sample token, queue and payments. Do not travel using this information.',
                  'केवल अभ्यास · टोकन, कतार और भुगतान नमूने हैं। इनके आधार पर केंद्र न जाएँ।',
                ),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xff654311),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PracticePage extends StatelessWidget {
  final Widget child;
  const PracticePage({super.key, required this.child});
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xffffedce),
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const PracticeBanner(),
          Expanded(child: child),
        ],
      ),
    ),
  );
}
