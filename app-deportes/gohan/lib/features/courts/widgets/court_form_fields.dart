import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sports/providers/sports_providers.dart';

/// Campos del alta de cancha: nombre, deporte, precio y techada.
class CourtFormFields extends ConsumerWidget {
  const CourtFormFields({
    super.key,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.sportId,
    required this.onSport,
    required this.indoor,
    required this.onIndoor,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final int? sportId;
  final ValueChanged<int> onSport;
  final bool indoor;
  final ValueChanged<bool> onIndoor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in sports)
              ChoiceChip(
                label: Text(s.name),
                selected: sportId == s.id,
                onSelected: (_) => onSport(s.id),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Precio por hora (\$)'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Techada'),
          value: indoor,
          onChanged: onIndoor,
        ),
      ],
    );
  }
}
