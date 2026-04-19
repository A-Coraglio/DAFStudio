import 'package:flutter/material.dart';

/// "3/10 jugadores" pill. Colors to hint full vs open.
class GamePlayersPill extends StatelessWidget {
  const GamePlayersPill({
    super.key,
    required this.current,
    required this.max,
  });

  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final full = current >= max;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.group,
          size: 16,
          color: full ? scheme.error : scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '$current/$max',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: full ? scheme.error : null,
                fontWeight: full ? FontWeight.w600 : null,
              ),
        ),
      ],
    );
  }
}
