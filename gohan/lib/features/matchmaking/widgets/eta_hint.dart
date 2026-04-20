import 'package:flutter/material.dart';

/// Coarse ETA banner shown under the queue timer. Hidden when the backend
/// can't estimate (too few waiters). Copy is intentionally vague — the
/// heuristic on the backend is bucketed, not precise.
class EtaHint extends StatelessWidget {
  const EtaHint({
    super.key,
    required this.estimatedWaitSeconds,
    required this.queueDepth,
  });

  final int? estimatedWaitSeconds;
  final int? queueDepth;

  String? _copy() {
    if (estimatedWaitSeconds == null) {
      if (queueDepth != null && queueDepth! <= 1) {
        return 'Sos el único en cola ahora. Puede tardar.';
      }
      return null;
    }
    if (estimatedWaitSeconds! <= 30) return 'Empareje inminente.';
    if (estimatedWaitSeconds! <= 180) return 'Espera estimada: ~2 min.';
    return 'Espera estimada: algunos minutos.';
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy();
    if (copy == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        copy,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
