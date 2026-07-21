import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/labels.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/tile_list_skeleton.dart';
import '../../profile/widgets/profile_avatar.dart';
import '../providers/tournament_detail_providers.dart';

/// "Inscriptos" section of the tournament detail: every enrolled player,
/// tappable through to their public profile.
class TournamentParticipantsCard extends ConsumerWidget {
  const TournamentParticipantsCard({super.key, required this.tournamentId});

  final int tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tournamentParticipantsProvider(tournamentId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Inscriptos',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 4),
            async.when(
              loading: () => const TileListSkeleton(rows: 3, shrinkWrap: true),
              error: (err, _) => ErrorView(
                error: err,
                message: 'No pudimos cargar los inscriptos.',
                onRetry: () => ref.invalidate(
                  tournamentParticipantsProvider(tournamentId),
                ),
              ),
              data: (participants) => participants.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nadie se inscribió todavía. ¡Sé el primero!'),
                    )
                  : Column(
                      children: [
                        for (final p in participants)
                          ListTile(
                            leading: ProfileAvatar(
                              avatarUrl: p.avatarUrl,
                              initials: p.initials,
                              radius: 20,
                            ),
                            title: Text(p.displayName),
                            subtitle: p.level == null
                                ? null
                                : Text(levelLabel(p.level)),
                            onTap: () =>
                                context.push('/players/${p.playerId}'),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
