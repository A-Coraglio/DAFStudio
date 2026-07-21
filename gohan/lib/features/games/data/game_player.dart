/// A participant of a game enriched with their profile data, as returned by
/// `GET /api/games/{id}/players/`.
class GamePlayer {
  final int gameId;
  final int playerId;

  /// Chosen slot (0..max_players-1); first half of the slots is the home
  /// side. Null = joined without picking a spot.
  final int? position;
  final DateTime createdAt;
  final String? firstName;
  final String? lastName;
  final String? level;
  final int rankingPoints;
  final String? avatarUrl;

  const GamePlayer({
    required this.gameId,
    required this.playerId,
    required this.position,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.level,
    required this.rankingPoints,
    required this.avatarUrl,
  });

  factory GamePlayer.fromJson(Map<String, dynamic> json) => GamePlayer(
    gameId: json['game_id'] as int,
    playerId: json['player_id'] as int,
    position: json['position'] as int?,
    createdAt: DateTime.parse(json['created_at'] as String),
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    level: json['level'] as String?,
    rankingPoints: (json['ranking_points'] as int?) ?? 0,
    avatarUrl: json['avatar_url'] as String?,
  );

  String get displayName {
    final name = [
      firstName,
      lastName,
    ].where((s) => s != null && s.isNotEmpty).join(' ').trim();
    return name.isEmpty ? 'Jugador #$playerId' : name;
  }

  String get initials {
    final a = (firstName ?? '').trim();
    final b = (lastName ?? '').trim();
    final s = '${a.isEmpty ? '' : a[0]}${b.isEmpty ? '' : b[0]}'.toUpperCase();
    return s.isEmpty ? '?' : s;
  }
}
