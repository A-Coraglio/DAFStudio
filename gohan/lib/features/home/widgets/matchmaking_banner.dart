import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final copy = switch (ticket.status) {
      TicketStatus.waiting => ('Buscando partido...', 'Tocá para ver el estado'),
      TicketStatus.matched => ('Partido listo', 'Entrá al lobby'),
      _ => ('¡Partido encontrado!', 'Aceptá antes de que se venza'),
    };

    return Card(
      color: urgent ? scheme.tertiaryContainer : scheme.surfaceContainerHigh,
      child: ListTile(
        leading: urgent
            ? Icon(Icons.notifications_active, color: scheme.tertiary)
            : const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
        title: Text(copy.$1),
        subtitle: Text(copy.$2),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/matchmaking'),
      ),
    );
  }
}
