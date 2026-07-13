class Sport {
  final int id;
  final String name;
  final int maxPlayersPerTeam;

  const Sport({
    required this.id,
    required this.name,
    required this.maxPlayersPerTeam,
  });

  factory Sport.fromJson(Map<String, dynamic> json) => Sport(
    id: json['id'] as int,
    name: json['name'] as String,
    maxPlayersPerTeam: json['max_players_per_team'] as int,
  );

  @override
  bool operator ==(Object other) => other is Sport && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
