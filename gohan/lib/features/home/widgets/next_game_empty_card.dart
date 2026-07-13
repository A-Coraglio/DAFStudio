import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shown in place of [NextGameCard]'s hero when the user has no upcoming
/// game — nudges them into the feed instead of showing an empty slot.
class NextGameEmptyCard extends StatelessWidget {
  const NextGameEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.sports_score,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No tenés partidos próximos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Buscá uno abierto cerca tuyo y sumate',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              // Compact height — the themed 52px CTA is too tall in a card row.
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: () => context.go('/games'),
              child: const Text('Buscar'),
            ),
          ],
        ),
      ),
    );
  }
}
