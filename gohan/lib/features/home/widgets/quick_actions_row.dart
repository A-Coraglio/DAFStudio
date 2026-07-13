import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Compact grid of the four main actions. Replaces the old full-width CTA
/// cards — Chats lives in the bottom nav, so it's not repeated here.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.bolt,
          label: 'Jugar ya',
          onTap: () => context.go('/matchmaking'),
        ),
        _QuickAction(
          icon: Icons.add,
          label: 'Crear',
          onTap: () => context.push('/games/new'),
        ),
        _QuickAction(
          icon: Icons.history,
          label: 'Mis partidos',
          onTap: () => context.push('/my-games'),
        ),
        _QuickAction(
          icon: Icons.person_search,
          label: 'Jugadores',
          onTap: () => context.push('/players'),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.secondaryContainer,
                child: Icon(icon, color: scheme.onSecondaryContainer),
              ),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
