/// Mirrors backend `PlayerStatsOutputDTO`. W/L/D refer to competitive games
/// only; casual is reported separately and never moves the ranking.
class PlayerStats {
  final int? sportId; // null = all-sports aggregate
  final int rankingPoints;
  final int totalPlayed;
  final int wins;
  final int losses;
  final int draws;
  final int casualPlayed;

  const PlayerStats({
    required this.sportId,
    required this.rankingPoints,
    required this.totalPlayed,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.casualPlayed,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    sportId: json['sport_id'] as int?,
    rankingPoints: json['ranking_points'] as int,
    totalPlayed: json['total_played'] as int,
    wins: json['wins'] as int,
    losses: json['losses'] as int,
    draws: json['draws'] as int,
    casualPlayed: json['casual_played'] as int,
  );

  double? get winRate {
    if (totalPlayed == 0) return null;
    return wins / totalPlayed;
  }
}
