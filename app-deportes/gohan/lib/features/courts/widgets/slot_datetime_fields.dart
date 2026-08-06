import 'package:flutter/material.dart';

import '../../../core/format/dates.dart';

/// Fecha / hora de inicio / duración del alta de turno.
class SlotDatetimeFields extends StatelessWidget {
  const SlotDatetimeFields({
    super.key,
    required this.date,
    required this.time,
    required this.minutes,
    required this.onDate,
    required this.onTime,
    required this.onMinutes,
  });

  final DateTime? date;
  final TimeOfDay? time;
  final int minutes;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<TimeOfDay> onTime;
  final ValueChanged<int> onMinutes;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(date == null ? 'Elegir fecha' : formatFullDate(date!)),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? now,
              firstDate: now,
              lastDate: now.add(const Duration(days: 90)),
            );
            if (picked != null) onDate(picked);
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule_outlined),
          title: Text(time == null ? 'Elegir hora' : time!.format(context)),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time ?? const TimeOfDay(hour: 18, minute: 0),
            );
            if (picked != null) onTime(picked);
          },
        ),
        Row(
          children: [
            for (final m in const [60, 90, 120]) ...[
              ChoiceChip(
                label: Text(m == 60 ? '1 h' : (m == 90 ? '1½ h' : '2 h')),
                selected: minutes == m,
                onSelected: (_) => onMinutes(m),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}
