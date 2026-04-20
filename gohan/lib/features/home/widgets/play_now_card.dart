import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../matchmaking/data/matchmaking_ticket.dart';
import '../../matchmaking/providers/matchmaking_providers.dart';

/// Home CTA for matchmaking. Watches the live ticket status so the user
/// always sees what's happening — queueing, proposal pending, lobby ready —
/// instead of a static "Jugar ya" that would mislead them into the form.
/// Tap always lands on /matchmaking; the screen itself renders the right
/// panel for the ticket's state.
class PlayNowCard extends ConsumerWidget {
  const PlayNowCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(matchmakingStatusStreamProvider);
    final copy = status.maybeWhen(
      data: (s) => _copyFor(s.ticket?.status),
      orElse: () => _idleCopy,
    );
    final highlight = status.maybeWhen(
      data: (s) => _isUrgent(s.ticket?.status),
      orElse: () => false,
    );
    final color = highlight
        ? Theme.of(context).colorScheme.primaryContainer
        : null;

    return Card(
      color: color,
      child: ListTile(
        leading: Icon(copy.icon),
        title: Text(copy.title),
        subtitle: Text(copy.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/matchmaking'),
      ),
    );
  }
}

class _Copy {
  const _Copy(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;
}

const _idleCopy = _Copy(
  Icons.bolt,
  'Jugar ya',
  'Matchmaking: te emparejamos con gente cerca',
);

_Copy _copyFor(TicketStatus? s) => switch (s) {
      TicketStatus.waiting => const _Copy(
          Icons.search,
          'Buscando partido...',
          'Tocá para ver el estado',
        ),
      TicketStatus.proposed || TicketStatus.accepted => const _Copy(
          Icons.notifications_active,
          '¡Partido encontrado!',
          'Aceptá antes de que se venza',
        ),
      TicketStatus.matched => const _Copy(
          Icons.check_circle,
          'Partido listo',
          'Entrá al lobby',
        ),
      _ => _idleCopy,
    };

bool _isUrgent(TicketStatus? s) =>
    s == TicketStatus.proposed ||
    s == TicketStatus.accepted ||
    s == TicketStatus.matched;
