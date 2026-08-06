/// A "class" offering = a teacher the user can take lessons with.
class ClassOffering {
  final int id;
  final int userId;
  final String displayName;
  final String? bio;
  final double pricePerHour;
  final int? experienceYears;
  final List<int> sportIds;
  final double? lat;
  final double? lon;
  final double? distanceKm;

  const ClassOffering({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.bio,
    required this.pricePerHour,
    required this.experienceYears,
    required this.sportIds,
    required this.lat,
    required this.lon,
    required this.distanceKm,
  });

  factory ClassOffering.fromJson(Map<String, dynamic> json) => ClassOffering(
    id: json['id'] as int,
    userId: json['user_id'] as int,
    displayName: json['display_name'] as String,
    bio: json['bio'] as String?,
    pricePerHour: (json['price_per_hour'] as num).toDouble(),
    experienceYears: json['experience_years'] as int?,
    sportIds: ((json['sport_ids'] as List<dynamic>?) ?? const [])
        .map((e) => e as int)
        .toList(),
    lat: (json['lat'] as num?)?.toDouble(),
    lon: (json['lon'] as num?)?.toDouble(),
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
  );
}
