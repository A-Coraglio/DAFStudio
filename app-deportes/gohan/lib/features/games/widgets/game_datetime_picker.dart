import 'package:flutter/material.dart';

/// Tile that opens date + time pickers sequentially and reports the combined
/// DateTime. `null` means "sin fecha".
class GameDateTimePicker extends StatelessWidget {
  const GameDateTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: value ?? now,
    );
    if (date == null) return;
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        value ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;
    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = value == null
        ? 'Sin fecha'
        : '${value!.day}/${value!.month}/${value!.year} '
              '${value!.hour.toString().padLeft(2, '0')}:'
              '${value!.minute.toString().padLeft(2, '0')}';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: const Text('Cuándo se juega'),
        subtitle: Text(label),
        trailing: value == null
            ? const Icon(Icons.chevron_right)
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onChanged(null),
              ),
        onTap: () => _pick(context),
      ),
    );
  }
}
