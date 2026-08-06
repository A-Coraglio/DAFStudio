/// Mi perfil de profesor (tabla teacher + deportes).
class TeacherProfile {
  final int id;
  final int userId;
  final String? bio;
  final double pricePerHour;
  final int? experienceYears;
  final List<int> sportIds;

  const TeacherProfile({
    required this.id,
    required this.userId,
    required this.bio,
    required this.pricePerHour,
    required this.experienceYears,
    required this.sportIds,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) => TeacherProfile(
    id: json['id'] as int,
    userId: json['user_id'] as int,
    bio: json['bio'] as String?,
    pricePerHour: (json['price_per_hour'] as num).toDouble(),
    experienceYears: json['experience_years'] as int?,
    sportIds: ((json['sport_ids'] as List<dynamic>?) ?? const [])
        .map((e) => e as int)
        .toList(),
  );
}
