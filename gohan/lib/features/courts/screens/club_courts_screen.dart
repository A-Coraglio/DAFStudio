import 'package:flutter/material.dart';

import '../data/club.dart';
import '../data/court.dart';
import '../widgets/court_card.dart';

/// Menú de un predio: todas las canchas de un club. Se llega desde el
/// picker cuando el club tiene más de una cancha; devuelve la elegida.
class ClubCourtsScreen extends StatelessWidget {
  const ClubCourtsScreen({
    super.key,
    required this.club,
    required this.courts,
    required this.sportName,
    required this.day,
  });

  final Club club;
  final List<Court> courts;
  final String? sportName;
  final DateTime day;

  static Future<Court?> push(
    BuildContext context, {
    required Club club,
    required List<Court> courts,
    required String? sportName,
    required DateTime day,
  }) {
    return Navigator.of(context).push<Court>(
      MaterialPageRoute(
        builder: (_) => ClubCourtsScreen(
          club: club,
          courts: courts,
          sportName: sportName,
          day: day,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(club.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${club.address} · ${club.city}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (final c in courts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourtCard(
                court: c,
                sportName: sportName,
                day: day,
                onTap: () => Navigator.of(context).pop(c),
              ),
            ),
        ],
      ),
    );
  }
}
