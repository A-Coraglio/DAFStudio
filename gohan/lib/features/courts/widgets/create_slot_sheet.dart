import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_snackbar.dart';
import '../../../core/widgets/primary_submit_button.dart';
import '../providers/courts_providers.dart';
import 'slot_datetime_fields.dart';

/// Alta de un turno: fecha, hora de inicio y duración.
class CreateSlotSheet extends ConsumerStatefulWidget {
  const CreateSlotSheet({super.key, required this.courtId});

  final int courtId;

  static Future<void> show(BuildContext context, int courtId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreateSlotSheet(courtId: courtId),
    );
  }

  @override
  ConsumerState<CreateSlotSheet> createState() => _CreateSlotSheetState();
}

class _CreateSlotSheetState extends ConsumerState<CreateSlotSheet> {
  DateTime? _date;
  TimeOfDay? _time;
  int _minutes = 60;
  bool _busy = false;

  Future<void> _submit() async {
    final d = _date!;
    final t = _time!;
    final start = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState(() => _busy = true);
    try {
      await ref.read(courtSlotsRepositoryProvider).create(
            widget.courtId,
            start: start,
            end: start.add(Duration(minutes: _minutes)),
          );
      ref.invalidate(courtSlotsProvider(widget.courtId));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno creado')),
      );
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nuevo turno', style: Theme.of(context).textTheme.titleMedium),
          SlotDatetimeFields(
            date: _date,
            time: _time,
            minutes: _minutes,
            onDate: (d) => setState(() => _date = d),
            onTime: (t) => setState(() => _time = t),
            onMinutes: (m) => setState(() => _minutes = m),
          ),
          const SizedBox(height: 16),
          PrimarySubmitButton(
            label: 'Crear turno',
            loading: _busy,
            onPressed: _date == null || _time == null ? null : _submit,
          ),
        ],
      ),
    );
  }
}
