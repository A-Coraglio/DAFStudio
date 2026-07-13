import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../matchmaking/data/matchmaking_ticket.dart';
import '../../matchmaking/providers/matchmaking_providers.dart';

/// Live matchmaking status, shown only while a ticket is active — idle users
/// reach matchmaking through the "Jugar ya" quick action instead. Urgent
/// states (proposal / lobby ready) get the loudest container color.
class MatchmakingBanner extends ConsumerWidget {
  const MatchmakingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(matchmakingStatusStreamProvider).valueOrNull;
    final ticket = status?.ticket;
    if (ticket == null || !ticket.status.isActive) {
      return const SizedBox.shrink();
    }

    final urgent = ticket.status != TicketStatus.waiting;
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final copy = switch (ticket.status) {
      TicketStatus.waiting => (
        'Buscando partido...',
        'Tocá para ver el estado',
      ),
      TicketStatus.matched => ('¡Partido listo!', 'Tu grupo te espera'),
      _ => ('¡Partido encontrado!', 'Aceptá antes de que se venza'),
    };

    // Urgent = full accent: this is the one banner that must scream.
    return Card(
      color: urgent ? colors.accent : scheme.surfaceContainerHigh,
      child: ListTile(
        leading: urgent
            ? Icon(Icons.notifications_active, color: colors.onAccent)
            : const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
        title: Text(
          copy.$1,
          style: urgent
              ? TextStyle(color: colors.onAccent, fontWeight: FontWeight.w700)
              : null,
        ),
        subtitle: Text(
          copy.$2,
          style: urgent ? TextStyle(color: colors.onAccent) : null,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: urgent ? colors.onAccent : null,
        ),
        onTap: () => context.go('/matchmaking'),
      ),
    );
  }
}
