import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sport_model.dart';
import '../providers/sports_providers.dart';

/// Dropdown bound to the live sports list from the backend. Null means "no
/// choice yet"; the validator forces the user to pick one.
class SportDropdownField extends ConsumerWidget {
  const SportDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Deporte favorito',
  });

  final int? value;
  final ValueChanged<int?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportsAsync = ref.watch(sportsListProvider);
    return sportsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (err, _) => Text(
        'No pudimos cargar los deportes: $err',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (sports) => DropdownButtonFormField<int>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: sports
            .map((Sport s) => DropdownMenuItem<int>(
                  value: s.id,
                  child: Text(s.name),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Elegí un deporte' : null,
      ),
    );
  }
}
