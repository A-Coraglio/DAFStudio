import 'package:flutter/material.dart';

/// Human-readable schedule line: "Hoy 20:00", "Mañana 18:30", "vie 21 18:00"
/// or "Sin fecha".
class GameScheduleText extends StatelessWidget {
  const GameScheduleText({super.key, required this.scheduledAt});

  final DateTime? scheduledAt;

  static const _weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

  String _format(DateTime d) {
    final now = DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = day.difference(today).inDays;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    if (diff == 0) return 'Hoy $hh:$mm';
    if (diff == 1) return 'Mañana $hh:$mm';
    if (diff > 1 && diff < 7) {
      return '${_weekdays[d.weekday - 1]} ${d.day} $hh:$mm';
    }
    return '${d.day}/${d.month} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final label = scheduledAt == null ? 'Sin fecha' : _format(scheduledAt!);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule, size: 16),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
