import 'package:flutter/material.dart';

/// Icon + label chip used by detail cards (tournaments, classes) to render
/// facts like dates, capacity or price.
class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
