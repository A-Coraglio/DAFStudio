/// Immutable filter set for the player discovery screen. Used as the family
/// key for [playerSearchProvider] so identical filters share the same in-flight
/// fetch and cache entry.
class PlayerSearchQuery {
  const PlayerSearchQuery({
    this.query,
    this.sportId,
    this.level,
    this.limit = 30,
  });

  final String? query;
  final int? sportId;
  final String? level;
  final int limit;

  bool get isEmpty =>
      (query == null || query!.isEmpty) && sportId == null && level == null;

  PlayerSearchQuery copyWith({
    String? query,
    int? sportId,
    String? level,
    bool clearQuery = false,
    bool clearSport = false,
    bool clearLevel = false,
  }) {
    return PlayerSearchQuery(
      query: clearQuery ? null : (query ?? this.query),
      sportId: clearSport ? null : (sportId ?? this.sportId),
      level: clearLevel ? null : (level ?? this.level),
      limit: limit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerSearchQuery &&
          other.query == query &&
          other.sportId == sportId &&
          other.level == level &&
          other.limit == limit;

  @override
  int get hashCode => Object.hash(query, sportId, level, limit);
}
