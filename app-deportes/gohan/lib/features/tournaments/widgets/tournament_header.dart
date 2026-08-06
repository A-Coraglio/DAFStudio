import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/labels.dart';
import '../../../core/theme/app_colors.dart';
import '../../sports/providers/sports_providers.dart';
import '../../sports/widgets/sport_thumbnail.dart';
import '../data/tournament_model.dart';

/// Header row of the tournament detail: sport thumbnail, name and status.
class TournamentHeader extends ConsumerWidget {
  const TournamentHeader({super.key, required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    String? sportName;
    for (final s in sports) {
      if (s.id == tournament.sportId) sportName = s.name;
    }
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SportThumbnail(
          sportName: sportName,
          size: 56,
          borderRadius: AppRadius.input,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tournament.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                tournamentStatusLabel(tournament.status),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
