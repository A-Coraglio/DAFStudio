class Tournament {
  final int id;
  final int organizerId;
  final int sportId;
  final int? clubId;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final String status;
  final String? level;
  final double? lat;
  final double? lon;
  final int participantCount;
  final double? distanceKm;

  const Tournament({
    required this.id,
    required this.organizerId,
    required this.sportId,
    required this.clubId,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.status,
    required this.level,
    required this.lat,
    required this.lon,
    required this.participantCount,
    required this.distanceKm,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
    id: json['id'] as int,
    organizerId: json['organizer_id'] as int,
    sportId: json['sport_id'] as int,
    clubId: json['club_id'] as int?,
    name: json['name'] as String,
    description: json['description'] as String?,
    startDate: DateTime.parse(json['start_date'] as String),
    endDate: DateTime.parse(json['end_date'] as String),
    maxParticipants: json['max_participants'] as int,
    status: json['status'] as String,
    level: json['level'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lon: (json['lon'] as num?)?.toDouble(),
    participantCount: json['participant_count'] as int? ?? 0,
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
  );
}
