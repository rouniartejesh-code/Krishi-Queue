import 'package:flutter/material.dart';

class SupportQuickActions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;
  final String title;

  const SupportQuickActions({
    super.key,
    required this.suggestions,
    required this.onSelected,
    this.title = 'Quick help',
  });

  IconData _iconFor(String value) {
    final q = value.toLowerCase();
    if (q.contains('token') || q.contains('qr')) return Icons.confirmation_number_outlined;
    if (q.contains('queue') || q.contains('wait')) return Icons.location_on_outlined;
    if (q.contains('book') || q.contains('slot')) return Icons.calendar_month_outlined;
    if (q.contains('payment') || q.contains('bill')) return Icons.payments_outlined;
    if (q.contains('price') || q.contains('market')) return Icons.trending_up;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((item) {
            return ActionChip(
              avatar: Icon(_iconFor(item), size: 18),
              label: Text(item),
              onPressed: () => onSelected(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
