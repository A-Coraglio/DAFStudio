import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/courts_providers.dart';

/// Par de selectores del flujo de reserva: primero el club, después una de
/// sus canchas.
class ClubCourtPickers extends ConsumerWidget {
  const ClubCourtPickers({
    super.key,
    required this.clubId,
    required this.courtId,
    required this.onClub,
    required this.onCourt,
  });

  final int? clubId;
  final int? courtId;
  final ValueChanged<int> onClub;
  final ValueChanged<int> onCourt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(clubsProvider).valueOrNull ?? const [];
    final courts = clubId == null
        ? null
        : ref.watch(clubCourtsProvider(clubId!)).valueOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Club', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final club in clubs)
              ChoiceChip(
                label: Text(club.name),
                selected: clubId == club.id,
                onSelected: (_) => onClub(club.id),
              ),
          ],
        ),
        if (courts != null) ...[
          const SizedBox(height: 16),
          Text('Cancha', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          if (courts.isEmpty)
            const Text('Este club todavía no cargó canchas.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final court in courts)
                  ChoiceChip(
                    label: Text(court.name),
                    selected: courtId == court.id,
                    onSelected: (_) => onCourt(court.id),
                  ),
              ],
            ),
        ],
      ],
    );
  }
}
