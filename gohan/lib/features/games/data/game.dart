/// Matches the backend `GamesOutputDTO` returned by `/api/games/`.
class Game {
  final int id;
  final String name;
  final int sportId;
  final int organizerId;
  final int? courtId;
  final int maxPlayers;
  final int currentPlayers;
  final String? level;
  final String mode;      // casual | competitive | matchmaking
  final String status;    // open | full | finished | cancelled | pending_acceptance
  final DateTime? scheduledAt;
  final int? resultHome;
  final int? resultAway;
  final DateTime createdAt;

  const Game({
    required this.id,
    required this.name,
    required this.sportId,
    required this.organizerId,
    required this.courtId,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.level,
    required this.mode,
    required this.status,
    required this.scheduledAt,
    required this.resultHome,
    required this.resultAway,
    required this.createdAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as int,
        name: json['name'] as String,
        sportId: json['sport_id'] as int,
        organizerId: json['organizer_id'] as int,
        courtId: json['court_id'] as int?,
        maxPlayers: json['max_players'] as int,
        currentPlayers: (json['current_players'] as int?) ?? 0,
        level: json['level'] as String?,
        mode: json['mode'] as String,
        status: json['status'] as String,
        scheduledAt: _parseIso(json['scheduled_at']),
        resultHome: json['result_home'] as int?,
        resultAway: json['result_away'] as int?,
        createdAt: _parseIso(json['created_at'])!,
      );

  static DateTime? _parseIso(Object? v) =>
      v is String ? DateTime.parse(v) : null;

  bool get isJoinable => status == 'open' && currentPlayers < maxPlayers;
  bool get isFull => currentPlayers >= maxPlayers;
}
