import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_card.dart';
import 'play_now_card.dart';

/// The three main actions on the home screen. All three are wired to real
/// screens after Fase 4+5. The first card is live and reflects the
/// matchmaking ticket state when the user has one active.
class HomeCtaList extends StatelessWidget {
  const HomeCtaList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PlayNowCard(),
        HomeCard(
          icon: Icons.list_alt,
          title: 'Explorar partidos',
          subtitle: 'Unite a partidos abiertos en tu zona',
          onTap: () => context.go('/games'),
        ),
        HomeCard(
          icon: Icons.add_circle_outline,
          title: 'Crear partido',
          subtitle: 'Armá uno y esperá jugadores',
          onTap: () => context.push('/games/new'),
        ),
        HomeCard(
          icon: Icons.chat_bubble_outline,
          title: 'Chats',
          subtitle: 'Conversaciones generales y de tus partidos',
          onTap: () => context.go('/chats'),
        ),
      ],
    );
  }
}
