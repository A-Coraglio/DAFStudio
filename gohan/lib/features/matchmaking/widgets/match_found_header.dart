import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// "¡Partido encontrado!" headline con micro-animación de entrada: el bolt
/// dorado hace un pop (scale con overshoot) y el texto aparece en fade.
class MatchFoundHeader extends StatelessWidget {
  const MatchFoundHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.elasticOut,
      builder: (context, t, _) => Row(
        children: [
          Transform.scale(
            scale: t,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bolt, color: colors.onAccent),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Opacity(
              opacity: t.clamp(0, 1),
              child: Text(
                '¡Partido encontrado!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
