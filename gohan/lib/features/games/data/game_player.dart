/// A participant of a game enriched with their profile data, as returned by
/// `GET /api/games/{id}/players/`.
class GamePlayer {
  final int gameId;
  final int playerId;
  final int? teamId;
  final DateTime createdAt;
  final String? firstName;
  final String? lastName;
  final String? level;
  final int rankingPoints;

  const GamePlayer({
    required this.gameId,
    required this.playerId,
    required this.teamId,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.level,
    required this.rankingPoints,
  });

  factory GamePlayer.fromJson(Map<String, dynamic> json) => GamePlayer(
    gameId: json['game_id'] as int,
    playerId: json['player_id'] as int,
    teamId: json['team_id'] as int?,
    createdAt: DateTime.parse(json['created_at'] as String),
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    level: json['level'] as String?,
    rankingPoints: (json['ranking_points'] as int?) ?? 0,
  );

  String get displayName {
    final name = [
      firstName,
      lastName,
    ].where((s) => s != null && s.isNotEmpty).join(' ').trim();
    return name.isEmpty ? 'Jugador #$playerId' : name;
  }
}
