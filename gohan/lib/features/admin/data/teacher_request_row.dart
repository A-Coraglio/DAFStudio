/// Solicitud de profe pendiente, como la ve el panel de admin.
class TeacherRequestRow {
  final int id;
  final int userId;
  final String displayName;
  final String? username;
  final String bio;
  final double pricePerHour;
  final int? experienceYears;
  final List<int> sportIds;
  final DateTime createdAt;

  const TeacherRequestRow({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.username,
    required this.bio,
    required this.pricePerHour,
    required this.experienceYears,
    required this.sportIds,
    required this.createdAt,
  });

  factory TeacherRequestRow.fromJson(Map<String, dynamic> json) =>
      TeacherRequestRow(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        displayName: json['display_name'] as String? ?? 'Usuario',
        username: json['username'] as String?,
        bio: json['bio'] as String,
        pricePerHour: (json['price_per_hour'] as num).toDouble(),
        experienceYears: json['experience_years'] as int?,
        sportIds: ((json['sport_ids'] as List<dynamic>?) ?? const [])
            .map((e) => e as int)
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
