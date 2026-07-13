import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile/providers/profile_providers.dart';

/// One-line mini stats under the home greeting: ranking + won/lost record.
/// Tapping lands on the Profile tab. Falls back to a friendly nudge while
/// stats load (or when the user hasn't played yet).
class HomeStatsLine extends ConsumerWidget {
  const HomeStatsLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(myProfileProvider).valueOrNull?.rankingPoints;
    final stats = ref.watch(myStatsProvider).valueOrNull;

    final style = Theme.of(context).textTheme.bodySmall;
    if (stats == null || stats.totalPlayed == 0) {
      return Text('¿Jugamos hoy?', style: style);
    }
    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Text(
        '${points ?? 0} pts · ${stats.wins}G ${stats.losses}P',
        style: style?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
