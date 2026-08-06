import 'package:flutter/material.dart';

import '../../../core/format/labels.dart';
import '../../../core/widgets/stat_chip.dart';
import '../data/tournament_model.dart';
import 'tournament_header.dart';

/// Header card of the tournament detail: sport, name, status, dates, level,
/// capacity and description.
class TournamentInfoCard extends StatelessWidget {
  const TournamentInfoCard({super.key, required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    final description = tournament.description;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TournamentHeader(tournament: tournament),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                StatChip(
                  icon: Icons.event_outlined,
                  label:
                      '${shortDate(tournament.startDate)} – ${shortDate(tournament.endDate)}',
                ),
                StatChip(
                  icon: Icons.groups_outlined,
                  label:
                      '${tournament.participantCount}/${tournament.maxParticipants} inscriptos',
                ),
                if (tournament.level != null)
                  StatChip(
                    icon: Icons.bar_chart,
                    label: levelLabel(tournament.level),
                  ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
