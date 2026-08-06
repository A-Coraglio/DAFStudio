import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/providers/profile_providers.dart';
import '../data/game.dart';
import '../data/game_player.dart';
import 'report_result_sheet.dart';

/// Secondary action on the detail screen: only surfaces the sheet when the
/// current user is a participant of a game that can still be scored
/// (open or full). Finished, cancelled and pending-acceptance games hide
/// the button entirely.
class ReportResultButton extends ConsumerWidget {
  const ReportResultButton({
    super.key,
    required this.game,
    required this.players,
  });

  final Game game;
  final List<GamePlayer> players;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPlayerId = ref.watch(myProfileProvider).valueOrNull?.id;
    final iAmIn =
        myPlayerId != null && players.any((p) => p.playerId == myPlayerId);
    final reportable = game.status == 'open' || game.status == 'full';
    if (!iAmIn || !reportable) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ReportResultSheet.show(context, game.id),
        icon: const Icon(Icons.flag),
        label: const Text('Reportar resultado'),
      ),
    );
  }
}
