import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

/// Compact grid of the four main actions. Replaces the old full-width CTA
/// cards — Chats lives in the bottom nav, so it's not repeated here.
/// "Jugar ya" flashes the energy accent: same treatment as the active tab
/// and the competitive badge.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.bolt,
          label: 'Jugar ya',
          emphasized: true,
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
        _QuickAction(
          icon: Icons.stadium_outlined,
          label: 'Reservar',
          onTap: () => context.push('/book-court'),
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
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final bg = emphasized ? colors.accent : scheme.secondaryContainer;
    final fg = emphasized ? colors.onAccent : scheme.onSecondaryContainer;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppRadius.tile),
                ),
                child: Icon(icon, color: fg),
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
