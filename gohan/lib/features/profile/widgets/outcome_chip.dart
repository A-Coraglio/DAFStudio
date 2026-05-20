import 'package:flutter/material.dart';

/// Color-coded chip for a player's result on a specific game. Used in the
/// "Mis partidos" list. Values match the backend `MyGameOutputDTO.outcome`:
/// won / lost / draw / pending.
class OutcomeChip extends StatelessWidget {
  const OutcomeChip({super.key, required this.outcome});

  final String outcome;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (outcome) {
      case 'won':
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade800;
        label = 'Ganado';
        break;
      case 'lost':
        bg = Colors.red.withValues(alpha: 0.15);
        fg = Colors.red.shade800;
        label = 'Perdido';
        break;
      case 'draw':
        bg = Colors.amber.withValues(alpha: 0.20);
        fg = Colors.amber.shade900;
        label = 'Empate';
        break;
      default:
        bg = scheme.surfaceContainerHighest;
        fg = scheme.onSurfaceVariant;
        label = 'Pendiente';
    }
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
