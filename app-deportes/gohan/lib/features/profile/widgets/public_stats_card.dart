import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/profile_providers.dart';

/// Read-only W/L/D strip for another player's public profile. Hidden while
/// loading/failing — the profile is still useful without it.
class PublicStatsCard extends ConsumerWidget {
  const PublicStatsCard({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatsProvider(playerId)).valueOrNull;
    if (stats == null || stats.totalPlayed == 0) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sus números', style: theme.textTheme.titleMedium),
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
          ],
        ),
      ),
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
