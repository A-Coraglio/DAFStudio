import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/illustrated_empty_state.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../data/club.dart';
import '../data/court.dart';
import '../providers/courts_providers.dart';
import '../widgets/court_card.dart';
import 'club_courts_screen.dart';

/// Resultado del picker: `court == null` significa "sin cancha" elegido a
/// propósito (distinto de cancelar, que devuelve null a secas).
class CourtSelection {
  const CourtSelection(this.court);
  final Court? court;
}

/// Pantalla de selección de cancha para crear partido. Nivel 1: clubes
/// (agrupados por predio) + canchas privadas propias + "sin cancha". Un club
/// con varias canchas abre su menú; con una sola, la selecciona directo.
class CourtPickerScreen extends ConsumerWidget {
  const CourtPickerScreen({
    super.key,
    required this.sportId,
    required this.sportName,
    required this.day,
  });

  final int? sportId;
  final String? sportName;
  final DateTime day;

  static Future<CourtSelection?> push(
    BuildContext context, {
    required int? sportId,
    required String? sportName,
    required DateTime day,
  }) {
    return Navigator.of(context).push<CourtSelection>(
      MaterialPageRoute(
        builder: (_) =>
            CourtPickerScreen(sportId: sportId, sportName: sportName, day: day),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courtsAsync = ref.watch(courtsForSportProvider(sportId));
    final clubs = ref.watch(clubsProvider).valueOrNull ?? const <Club>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Elegir cancha')),
      body: courtsAsync.when(
        loading: () => const TileListSkeleton(rows: 6),
        error: (err, _) => ErrorView(
          error: err,
          onRetry: () => ref.invalidate(courtsForSportProvider(sportId)),
        ),
        data: (courts) => _CourtsList(
          courts: courts,
          clubs: clubs,
          sportName: sportName,
          day: day,
        ),
      ),
    );
  }
}

class _CourtsList extends StatelessWidget {
  const _CourtsList({
    required this.courts,
    required this.clubs,
    required this.sportName,
    required this.day,
  });

  final List<Court> courts;
  final List<Club> clubs;
  final String? sportName;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final byClub = <int, List<Court>>{};
    final private = <Court>[];
    for (final c in courts) {
      if (c.clubId != null) {
        byClub.putIfAbsent(c.clubId!, () => []).add(c);
      } else {
        private.add(c);
      }
    }
    Club? clubOf(int id) {
      for (final cl in clubs) {
        if (cl.id == id) return cl;
      }
      return null;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.not_listed_location_outlined),
          title: const Text('Sin cancha'),
          subtitle: const Text('La definimos después'),
          onTap: () => Navigator.of(context).pop(const CourtSelection(null)),
        ),
        if (courts.isEmpty) ...[
          const SizedBox(height: 24),
          const IllustratedEmptyState(
            icon: Icons.stadium_outlined,
            title: 'No hay canchas para este deporte',
            body:
                'Podés crear el partido sin cancha y definirla más adelante.',
          ),
        ],
        if (byClub.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Clubes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final entry in byClub.entries)
            _clubEntry(context, clubOf(entry.key), entry.value),
        ],
        if (private.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Tus canchas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final c in private)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourtCard(
                court: c,
                sportName: sportName,
                day: day,
                onTap: () => Navigator.of(context).pop(CourtSelection(c)),
              ),
            ),
        ],
      ],
    );
  }

  /// Club con una sola cancha → la card selecciona directo. Con varias →
  /// tile del predio que abre su menú de canchas.
  Widget _clubEntry(BuildContext context, Club? club, List<Court> courts) {
    if (courts.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CourtCard(
          court: courts.first,
          sportName: sportName,
          day: day,
          onTap: () => Navigator.of(context).pop(CourtSelection(courts.first)),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.stadium_outlined),
        title: Text(club?.name ?? 'Club #${courts.first.clubId}'),
        subtitle: Text(
          club == null
              ? '${courts.length} canchas'
              : '${club.city} · ${courts.length} canchas',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final picked = await ClubCourtsScreen.push(
            context,
            club:
                club ??
                Club(
                  id: courts.first.clubId!,
                  ownerId: 0,
                  name: 'Club #${courts.first.clubId}',
                  address: '',
                  city: '',
                ),
            courts: courts,
            sportName: sportName,
            day: day,
          );
          if (picked != null && context.mounted) {
            Navigator.of(context).pop(CourtSelection(picked));
          }
        },
      ),
    );
  }
}
