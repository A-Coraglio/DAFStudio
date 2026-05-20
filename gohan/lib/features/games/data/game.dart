/// Matches the backend `GamesOutputDTO` returned by `/api/games/`.
class Game {
  final int id;
  final String name;
  final int sportId;
  /// Sport display name, joined server-side. Null only on the create/join/
  /// leave POST responses (no JOIN there); the feed and detail always set it.
  final String? sportName;
  /// Km to the game's court from the user. Set by the feed when location is
  /// available; null otherwise (no location, or game without a geo court).
  final double? distanceKm;
  final int organizerId;
  final int? courtId;
  final int maxPlayers;
  final int currentPlayers;
  final String? level;
  final String mode;      // casual | competitive
  final String status;    // open | full | finished | cancelled | pending_acceptance
  final DateTime? scheduledAt;
  final int? resultHome;
  final int? resultAway;
  final DateTime createdAt;
  /// How many participants have already reported a score. Only populated on
  /// the detail endpoint; list/feed responses leave it null.
  final int? confirmationsCount;
  final int? confirmationsTotal;
  /// Present only on /players/me/games/ — outcome of the game from the
  /// calling user's perspective. Values: won / lost / draw / pending.
  final String? outcome;
  /// Present only on /players/me/games/ — which side the user was on.
  /// Values: home / away / null (unsplittable game).
  final String? teamSide;

  const Game({
    required this.id,
    required this.name,
    required this.sportId,
    required this.sportName,
    required this.distanceKm,
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
    this.confirmationsCount,
    this.confirmationsTotal,
    this.outcome,
    this.teamSide,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as int,
        name: json['name'] as String,
        sportId: json['sport_id'] as int,
        sportName: json['sport_name'] as String?,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
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
        confirmationsCount: json['confirmations_count'] as int?,
        confirmationsTotal: json['confirmations_total'] as int?,
        outcome: json['outcome'] as String?,
        teamSide: json['team_side'] as String?,
      );

  static DateTime? _parseIso(Object? v) =>
      v is String ? DateTime.parse(v) : null;

  bool get isJoinable => status == 'open' && currentPlayers < maxPlayers;
  bool get isFull => currentPlayers >= maxPlayers;
}
