import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Small colored pill labeling the game mode. Consistent across feed +
/// detail. Competitive flashes the energy accent with a bolt so the
/// casual/competitive axis reads at a glance.
class GameModeBadge extends StatelessWidget {
  const GameModeBadge({super.key, required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final (label, bg, fg, icon) = switch (mode) {
      'casual' => (
        'Casual',
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        null,
      ),
      'competitive' => (
        'Competitivo',
        colors.accent,
        colors.onAccent,
        Icons.bolt,
      ),
      _ => (
        mode,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        null,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
