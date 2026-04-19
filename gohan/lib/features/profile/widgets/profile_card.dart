import 'package:flutter/material.dart';

import '../data/player_profile.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.favoriteSportName,
  });

  final PlayerProfile profile;
  final String? favoriteSportName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(profile.displayName),
            subtitle: Text('Jugador #${profile.id}'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.military_tech),
            title: const Text('Ranking'),
            subtitle: Text('${profile.rankingPoints} puntos'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.signal_cellular_alt),
            title: const Text('Nivel'),
            subtitle: Text(profile.level ?? 'Sin definir'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.sports),
            title: const Text('Deporte favorito'),
            subtitle: Text(favoriteSportName ?? 'Sin definir'),
          ),
        ],
      ),
    );
  }
}
