import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Color-coded chip for a player's result on a specific game. Used in the
/// "Mis partidos" list. Values match the backend `MyGameOutputDTO.outcome`:
/// won / lost / draw / pending. Colors come from the AppColors tokens so
/// they hold contrast in both light and dark mode.
class OutcomeChip extends StatelessWidget {
  const OutcomeChip({super.key, required this.outcome});

  final String outcome;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final (bg, fg, label) = switch (outcome) {
      'won' => (colors.winContainer, colors.onWinContainer, 'Ganado'),
      'lost' => (colors.loseContainer, colors.onLoseContainer, 'Perdido'),
      'draw' => (colors.drawContainer, colors.onDrawContainer, 'Empate'),
      _ => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        'Pendiente',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}
