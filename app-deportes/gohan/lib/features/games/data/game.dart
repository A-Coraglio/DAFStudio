import '../../../core/format/labels.dart';
import 'game_player.dart';

/// Rango de nivel de un partido alrededor del ranking del organizador.
/// Quien se une con ranking fuera de ±kLevelRange ve un aviso (pero puede
/// entrar igual — regla de producto explícita).
const kLevelRange = 500;

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

  /// Court display name, joined server-side. Null when the game has no court.
  final String? courtName;

  /// Court coordinates — only populated by the detail endpoint.
  final double? courtLat;
  final double? courtLon;

  /// Whether the current user participates. Only populated by the list
  /// endpoint; null elsewhere (detail derives it from the roster).
  final bool? isJoined;
  final int organizerId;

  /// Ranking del organizador — el ancla de nivel implícita del partido.
  /// La UI avisa a quien se une con ranking fuera de ±[kLevelRange].
  final int? organizerRankingPoints;
  final int? courtId;
  final int maxPlayers;
  final int currentPlayers;
  final String? level;
  final String mode; // casual | competitive
  final String
  status; // open | full | finished | cancelled | pending_acceptance
  final DateTime? scheduledAt;
  final int? resultHome;
  final int? resultAway;

  /// Per-set detail for set-based sports, e.g. "6-4,6-3". Null otherwise;
  /// resultHome/resultAway then hold the count of sets won.
  final String? sets;
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

  /// Roster with positions, joined server-side. Populated ONLY by the list
  /// endpoint (feed cards render slots from here without one request per
  /// card); null elsewhere — the detail screen uses gamePlayersProvider.
  final List<GamePlayer>? players;

  const Game({
    required this.id,
    required this.name,
    required this.sportId,
    required this.sportName,
    required this.distanceKm,
    this.courtName,
    this.courtLat,
    this.courtLon,
    this.isJoined,
    required this.organizerId,
    this.organizerRankingPoints,
    required this.courtId,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.level,
    required this.mode,
    required this.status,
    required this.scheduledAt,
    required this.resultHome,
    required this.resultAway,
    this.sets,
    required this.createdAt,
    this.confirmationsCount,
    this.confirmationsTotal,
    this.outcome,
    this.teamSide,
    this.players,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json['id'] as int,
    name: json['name'] as String,
    sportId: json['sport_id'] as int,
    sportName: json['sport_name'] as String?,
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
    courtName: json['court_name'] as String?,
    courtLat: (json['court_lat'] as num?)?.toDouble(),
    courtLon: (json['court_lon'] as num?)?.toDouble(),
    isJoined: json['is_joined'] as bool?,
    organizerId: json['organizer_id'] as int,
    organizerRankingPoints: json['organizer_ranking_points'] as int?,
    courtId: json['court_id'] as int?,
    maxPlayers: json['max_players'] as int,
    currentPlayers: (json['current_players'] as int?) ?? 0,
    level: json['level'] as String?,
    mode: json['mode'] as String,
    status: json['status'] as String,
    scheduledAt: _parseIso(json['scheduled_at']),
    resultHome: json['result_home'] as int?,
    resultAway: json['result_away'] as int?,
    sets: json['sets'] as String?,
    createdAt: _parseIso(json['created_at'])!,
    confirmationsCount: json['confirmations_count'] as int?,
    confirmationsTotal: json['confirmations_total'] as int?,
    outcome: json['outcome'] as String?,
    teamSide: json['team_side'] as String?,
    players: (json['players'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        .map(GamePlayer.fromJson)
        .toList(),
  );

  static DateTime? _parseIso(Object? v) =>
      v is String ? DateTime.parse(v) : null;

  /// Parsed per-set scores, e.g. "6-4,6-3" → [(home:6,away:4),(home:6,away:3)].
  /// Empty when the game has no set detail.
  List<({int home, int away})> get setScores {
    final s = sets;
    if (s == null || s.isEmpty) return const [];
    final result = <({int home, int away})>[];
    for (final part in s.split(',')) {
      final xy = part.split('-');
      if (xy.length != 2) continue;
      final h = int.tryParse(xy[0].trim());
      final a = int.tryParse(xy[1].trim());
      if (h != null && a != null) result.add((home: h, away: a));
    }
    return result;
  }

  bool get isJoinable => status == 'open' && currentPlayers < maxPlayers;
  bool get isFull => currentPlayers >= maxPlayers;

  /// Sufijo de nivel para cards: preferimos el ancla de ranking del
  /// organizador (~pts); el `level` enum queda para partidos viejos.
  String get levelSuffix {
    if (organizerRankingPoints != null) {
      return ' · Nivel ~$organizerRankingPoints pts';
    }
    if (level != null) return ' · ${levelLabel(level)}';
    return '';
  }
}
