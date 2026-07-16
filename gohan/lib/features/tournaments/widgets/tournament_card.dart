import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/labels.dart';
import '../../../core/theme/app_colors.dart';
import '../../sports/providers/sports_providers.dart';
import '../../sports/widgets/sport_thumbnail.dart';
import '../data/tournament_model.dart';

/// Card for a tournament — used both in the home carousel (fixed width) and in
/// the tournaments search list. Resolves the sport name from the cached sports
/// list to render the matching thumbnail.
class TournamentCard extends ConsumerWidget {
  const TournamentCard({super.key, required this.tournament, required this.onTap});

  final Tournament tournament;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportsListProvider).valueOrNull ?? const [];
    String? sportName;
    for (final s in sports) {
      if (s.id == tournament.sportId) sportName = s.name;
    }
    final scheme = Theme.of(context).colorScheme;
    final distance = distanceLabel(tournament.distanceKm);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportThumbnail(
                sportName: sportName,
                size: 52,
                borderRadius: AppRadius.input,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Chip(
                          icon: Icons.event_outlined,
                          label: shortDate(tournament.startDate),
                        ),
                        _Chip(
                          icon: Icons.groups_outlined,
                          label:
                              '${tournament.participantCount}/${tournament.maxParticipants}',
                        ),
                        if (tournament.level != null)
                          _Chip(
                            icon: Icons.bar_chart,
                            label: levelLabel(tournament.level),
                          ),
                        if (distance != null)
                          _Chip(icon: Icons.place_outlined, label: distance),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
