import 'package:flutter/material.dart';

/// Trailing card for home carousels: replaces the old "Ver todos" header
/// button. Always the last item, so the affordance appears where the user
/// actually is when they run out of cards.
class SeeMoreCard extends StatelessWidget {
  const SeeMoreCard({super.key, required this.onTap, this.label = 'Ver más'});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward, color: scheme.primary),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
