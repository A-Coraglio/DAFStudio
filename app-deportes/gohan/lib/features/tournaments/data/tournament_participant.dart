/// A player enrolled in a tournament, as listed in the detail screen.
class TournamentParticipant {
  final int playerId;
  final int userId;
  final String displayName;
  final String? level;
  final String? avatarUrl;
  final DateTime joinedAt;

  const TournamentParticipant({
    required this.playerId,
    required this.userId,
    required this.displayName,
    required this.level,
    required this.avatarUrl,
    required this.joinedAt,
  });

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) =>
      TournamentParticipant(
        playerId: json['player_id'] as int,
        userId: json['user_id'] as int,
        displayName: json['display_name'] as String,
        level: json['level'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        joinedAt: DateTime.parse(json['joined_at'] as String),
      );

  String get initials {
    final parts = displayName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
