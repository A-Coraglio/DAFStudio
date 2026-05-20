import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../games/data/game.dart';
import 'outcome_chip.dart';

/// One row in the personal history. Shows sport + scheduled date + final
/// score (or em-dash when unresolved) + the outcome chip. Tap → game detail.
class MyGameTile extends StatelessWidget {
  const MyGameTile({super.key, required this.game});

  final Game game;

  String _subtitle() {
    final parts = <String>[];
    if (game.sportName != null) parts.add(game.sportName!);
    parts.add(game.mode);
    if (game.scheduledAt != null) {
      final d = game.scheduledAt!;
      parts.add('${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}');
    }
    return parts.join(' · ');
  }

  String _score() {
    if (game.resultHome == null || game.resultAway == null) return '—';
    return '${game.resultHome} - ${game.resultAway}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(game.name),
      subtitle: Text(_subtitle()),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(_score(), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          OutcomeChip(outcome: game.outcome ?? 'pending'),
        ],
      ),
      onTap: () => context.push('/games/${game.id}'),
    );
  }
}
