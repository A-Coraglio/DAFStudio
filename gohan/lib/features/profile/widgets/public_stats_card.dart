import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Desempeño', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(label: 'Jugados', value: '${stats.totalPlayed}'),
                _Metric(label: 'Ganados', value: '${stats.wins}'),
                _Metric(label: 'Empatados', value: '${stats.draws}'),
                _Metric(label: 'Perdidos', value: '${stats.losses}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
