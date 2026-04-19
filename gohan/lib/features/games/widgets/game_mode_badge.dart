import 'package:flutter/material.dart';

/// Small colored pill labeling the game mode. Consistent across feed + detail.
class GameModeBadge extends StatelessWidget {
  const GameModeBadge({super.key, required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (mode) {
      'casual' => ('Casual', scheme.tertiaryContainer),
      'competitive' => ('Competitivo', scheme.primaryContainer),
      'matchmaking' => ('Matchmaking', scheme.secondaryContainer),
      _ => (mode, scheme.surfaceContainerHighest),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
