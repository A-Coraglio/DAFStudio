import 'package:flutter/material.dart';

import '../data/game.dart';

/// Aclara que el nivel del partido no se elige: sale del ranking del
/// creador. Cualquiera puede unirse igual; los que estén fuera del rango
/// ven un aviso antes de entrar.
class LevelAnchorHint extends StatelessWidget {
  const LevelAnchorHint({super.key, required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.speed, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nivel del partido: ~$points pts (tu ranking, ±$kLevelRange). '
              'Cualquiera puede unirse; si está fuera del rango, le avisamos.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
