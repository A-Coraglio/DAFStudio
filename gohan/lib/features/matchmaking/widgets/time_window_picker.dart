import 'package:flutter/material.dart';

enum TimeWindow {
  now,
  nextHour,
  today,
  tomorrow;

  (DateTime, DateTime) toRange() {
    final now = DateTime.now();
    return switch (this) {
      TimeWindow.now => (now, now.add(const Duration(minutes: 30))),
      TimeWindow.nextHour => (now, now.add(const Duration(hours: 1))),
      TimeWindow.today => (
          now,
          DateTime(now.year, now.month, now.day, 23, 59),
        ),
      TimeWindow.tomorrow => (
          DateTime(now.year, now.month, now.day + 1, 8),
          DateTime(now.year, now.month, now.day + 1, 23, 59),
        ),
    };
  }

  String get label => switch (this) {
        TimeWindow.now => 'Ahora',
        TimeWindow.nextHour => 'Próxima hora',
        TimeWindow.today => 'Hoy',
        TimeWindow.tomorrow => 'Mañana',
      };
}

/// Horizontal chips that resolve to (window_start, window_end) pairs.
class TimeWindowPicker extends StatelessWidget {
  const TimeWindowPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TimeWindow value;
  final ValueChanged<TimeWindow> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final w in TimeWindow.values) ...[
            ChoiceChip(
              label: Text(w.label),
              selected: value == w,
              onSelected: (_) => onChanged(w),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
