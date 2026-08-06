import 'package:flutter/material.dart';

import '../../../core/format/dates.dart';

/// Human-readable schedule line: "Hoy 20:00", "Mañana 18:30", "vie 21 18:00"
/// or "Sin fecha". Formatting lives in core/format/dates.dart.
class GameScheduleText extends StatelessWidget {
  const GameScheduleText({
    super.key,
    required this.scheduledAt,
    this.bold = false,
  });

  final DateTime? scheduledAt;

  /// Feed cards emphasize the time — it's the first thing a browser scans.
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule, size: 16),
        const SizedBox(width: 4),
        Text(
          formatSchedule(scheduledAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: bold ? FontWeight.w700 : null,
          ),
        ),
      ],
    );
  }
}
