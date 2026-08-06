import 'package:flutter/material.dart';

class GameStatusChip extends StatelessWidget {
  const GameStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      'open' => ('Abierto', scheme.primaryContainer),
      'full' => ('Lleno', scheme.tertiaryContainer),
      'finished' => ('Finalizado', scheme.surfaceContainerHighest),
      'cancelled' => ('Cancelado', scheme.errorContainer),
      'pending_acceptance' => (
        'Esperando aceptación',
        scheme.secondaryContainer,
      ),
      _ => (status, scheme.surfaceContainerHighest),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
