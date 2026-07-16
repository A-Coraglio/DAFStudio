import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/court.dart';
import '../providers/courts_providers.dart';

/// Optional court picker. Shows courts available for the selected sport —
/// null sport means "show all". "Sin cancha" is always a valid choice;
/// matchmaking will resolve the venue later, casual games can play anywhere.
class CourtPickerField extends ConsumerWidget {
  const CourtPickerField({
    super.key,
    required this.sportId,
    required this.value,
    required this.onChanged,
  });

  final int? sportId;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courtsAsync = ref.watch(courtsForSportProvider(sportId));
    return courtsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (err, _) => Text(
        'No pudimos cargar las canchas.',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (courts) => DropdownButtonFormField<int?>(
        initialValue: value,
        decoration: const InputDecoration(labelText: 'Cancha (opcional)'),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('Sin cancha')),
          for (final c in courts)
            DropdownMenuItem<int?>(value: c.id, child: Text(_label(c))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  String _label(Court c) {
    final suffix = c.isPrivate ? ' (privada)' : '';
    return '${c.name}$suffix';
  }
}
