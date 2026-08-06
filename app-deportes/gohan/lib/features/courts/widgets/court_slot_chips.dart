import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/courts_providers.dart';

/// Horarios del día para una cancha. No hay sistema de reservas: se muestran
/// los partidos ya agendados en esa cancha ese día como franjas ocupadas —
/// lo demás se asume libre.
class CourtSlotChips extends ConsumerWidget {
  const CourtSlotChips({super.key, required this.courtId, required this.day});

  final int courtId;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(
      courtDayGamesProvider((courtId: courtId, day: day)),
    );
    final scheme = Theme.of(context).colorScheme;
    return gamesAsync.when(
      loading: () => const SizedBox(height: 24),
      error: (_, _) => const SizedBox.shrink(),
      data: (games) {
        final taken =
            games
                .where((g) => g.status != 'cancelled' && g.scheduledAt != null)
                .toList()
              ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
        if (taken.isEmpty) {
          return Text(
            'Libre todo el día',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        return Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Ocupada:', style: Theme.of(context).textTheme.bodySmall),
            for (final g in taken)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  TimeOfDay.fromDateTime(g.scheduledAt!).format(context),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
