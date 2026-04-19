class PlayerProfile {
  final int id;
  final int userId;
  final String? firstName;
  final String? lastName;
  final String? level;
  final int rankingPoints;
  final int? favoriteSportId;

  const PlayerProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.level,
    required this.rankingPoints,
    required this.favoriteSportId,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        level: json['level'] as String?,
        rankingPoints: json['ranking_points'] as int,
        favoriteSportId: json['favorite_sport_id'] as int?,
      );

  /// True when the user has completed the onboarding step — we only require
  /// name + surname + favorite sport. Level is still optional.
  bool get isComplete =>
      (firstName?.isNotEmpty ?? false) &&
      (lastName?.isNotEmpty ?? false) &&
      favoriteSportId != null;

  String get displayName {
    final name = [firstName, lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ')
        .trim();
    return name.isEmpty ? 'Jugador #$id' : name;
  }
}

class UpdatePlayerRequest {
  final String? firstName;
  final String? lastName;
  final String? level;
  final int? favoriteSportId;

  const UpdatePlayerRequest({
    this.firstName,
    this.lastName,
    this.level,
    this.favoriteSportId,
  });

  Map<String, dynamic> toJson() => {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (level != null) 'level': level,
        if (favoriteSportId != null) 'favorite_sport_id': favoriteSportId,
      };
}
