/// Mirrors the backend `TICKET_STATES` tuple in
/// `apps/matchmaking/models/ddo.py`. Keep in sync.
enum TicketStatus {
  waiting,
  proposed,
  accepted,
  matched,
  cancelled,
  expired,
  rejected;

  static TicketStatus fromString(String v) => values.firstWhere(
        (s) => s.name == v,
        orElse: () => TicketStatus.cancelled,
      );

  bool get isActive =>
      this == TicketStatus.waiting ||
      this == TicketStatus.proposed ||
      this == TicketStatus.accepted ||
      this == TicketStatus.matched;
}

class MatchmakingTicket {
  final int id;
  final int userId;
  final int sportId;
  final double maxRadiusKm;
  final double originLat;
  final double originLon;
  final DateTime windowStart;
  final DateTime windowEnd;
  final TicketStatus status;
  final int? matchedGameId;
  final DateTime createdAt;

  const MatchmakingTicket({
    required this.id,
    required this.userId,
    required this.sportId,
    required this.maxRadiusKm,
    required this.originLat,
    required this.originLon,
    required this.windowStart,
    required this.windowEnd,
    required this.status,
    required this.matchedGameId,
    required this.createdAt,
  });

  factory MatchmakingTicket.fromJson(Map<String, dynamic> json) =>
      MatchmakingTicket(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        sportId: json['sport_id'] as int,
        maxRadiusKm: (json['max_radius_km'] as num).toDouble(),
        originLat: (json['origin_lat'] as num).toDouble(),
        originLon: (json['origin_lon'] as num).toDouble(),
        windowStart: DateTime.parse(json['window_start'] as String),
        windowEnd: DateTime.parse(json['window_end'] as String),
        status: TicketStatus.fromString(json['status'] as String),
        matchedGameId: json['matched_game_id'] as int?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
