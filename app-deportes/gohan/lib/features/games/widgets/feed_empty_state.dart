import 'package:flutter/material.dart';

import '../../../core/widgets/illustrated_empty_state.dart';

/// Shown when the feed returns zero games for the current filters.
class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({super.key, this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return IllustratedEmptyState(
      icon: Icons.sports_tennis,
      title: 'No hay partidos abiertos',
      body: 'Probá cambiar el deporte o el modo, o creá vos uno.',
      action: onCreate == null
          ? null
          : FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear partido'),
            ),
    );
  }
}
