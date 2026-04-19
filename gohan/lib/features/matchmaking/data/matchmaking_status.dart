import '../../games/data/game.dart';
import 'matchmaking_ticket.dart';

/// Response of `GET /api/matchmaking/status/`. Both fields are nullable:
///  - `ticket` is null when the user has no active queue entry.
///  - `proposedGame` is non-null only during `proposed` / `accepted` /
///    `matched` states.
class MatchmakingStatus {
  final MatchmakingTicket? ticket;
  final Game? proposedGame;

  const MatchmakingStatus({required this.ticket, required this.proposedGame});

  factory MatchmakingStatus.fromJson(Map<String, dynamic> json) {
    final t = json['ticket'];
    final g = json['proposed_game'];
    return MatchmakingStatus(
      ticket: t == null
          ? null
          : MatchmakingTicket.fromJson(t as Map<String, dynamic>),
      proposedGame:
          g == null ? null : Game.fromJson(g as Map<String, dynamic>),
    );
  }
}
