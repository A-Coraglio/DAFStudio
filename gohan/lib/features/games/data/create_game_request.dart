/// Body for `POST /api/games/`. Mirrors `GameCreateInputDTO` on the backend.
///
/// Mode is intentionally limited to `casual` / `competitive` here — the
/// `matchmaking` mode is only produced by the quick-match queue, never by
/// a user-created game.
class CreateGameRequest {
  final String name;
  final int sportId;
  final int maxPlayers;
  final String mode;
  final int? courtId;
  final String? level;
  final DateTime? scheduledAt;

  const CreateGameRequest({
    required this.name,
    required this.sportId,
    required this.maxPlayers,
    required this.mode,
    required this.courtId,
    required this.level,
    required this.scheduledAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sport_id': sportId,
        'max_players': maxPlayers,
        'mode': mode,
        if (courtId != null) 'court_id': courtId,
        if (level != null) 'level': level,
        if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
      };
}
