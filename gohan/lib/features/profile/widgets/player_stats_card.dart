import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/profile_providers.dart';

/// Compact W/L/D + ranking strip shown above the user's profile actions.
/// Falls back silently when stats fail to load — the profile is still useful
/// without them.
class PlayerStatsCard extends ConsumerWidget {
  const PlayerStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myStatsProvider);
    return async.when(
      loading: () => const _StatsSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (stats) {
        final theme = Theme.of(context);
        final colors = theme.extension<AppColors>()!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tus números', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Metric(label: 'Jugados', value: '${stats.totalPlayed}'),
                    _Metric(
                      label: 'Ganados',
                      value: '${stats.wins}',
                      color: colors.win,
                    ),
                    _Metric(
                      label: 'Empatados',
                      value: '${stats.draws}',
                      color: colors.draw,
                    ),
                    _Metric(
                      label: 'Perdidos',
                      value: '${stats.losses}',
                      color: colors.lose,
                    ),
                  ],
                ),
                if (stats.totalPlayed > 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${(stats.wins * 100 / stats.totalPlayed).round()}% '
                    'de efectividad en competitivos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (stats.casualPlayed > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${stats.casualPlayed} casuales (no afectan ranking)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            // Tabular figures: los números "scoreboard" alinean parejo.
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) => const Card(
    child: SizedBox(
      height: 110,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    ),
  );
}
