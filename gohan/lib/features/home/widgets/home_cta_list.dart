import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_card.dart';

/// The three main actions on the home screen. All three are wired to real
/// screens after Fase 4+5.
class HomeCtaList extends StatelessWidget {
  const HomeCtaList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeCard(
          icon: Icons.bolt,
          title: 'Jugar ya',
          subtitle: 'Matchmaking: te emparejamos con gente cerca',
          onTap: () => context.push('/matchmaking'),
        ),
        HomeCard(
          icon: Icons.list_alt,
          title: 'Explorar partidos',
          subtitle: 'Unite a partidos abiertos en tu zona',
          onTap: () => context.push('/games'),
        ),
        HomeCard(
          icon: Icons.add_circle_outline,
          title: 'Crear partido',
          subtitle: 'Armá uno y esperá jugadores',
          onTap: () => context.push('/games/new'),
        ),
      ],
    );
  }
}
