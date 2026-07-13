import 'package:flutter/material.dart';

/// One-tap schedule shortcuts (Hoy 18:00, Mañana 20:00, ...) shown above the
/// full date picker. Options already in the past are hidden.
class QuickDateChips extends StatelessWidget {
  const QuickDateChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  List<(String, DateTime)> _options() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return [
      ('Hoy 18:00', today.add(const Duration(hours: 18))),
      ('Hoy 20:00', today.add(const Duration(hours: 20))),
      ('Mañana 18:00', tomorrow.add(const Duration(hours: 18))),
      ('Mañana 20:00', tomorrow.add(const Duration(hours: 20))),
    ].where((o) => o.$2.isAfter(now)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (label, at) in _options()) ...[
            ChoiceChip(
              label: Text(label),
              selected: value == at,
              onSelected: (_) => onChanged(at),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
