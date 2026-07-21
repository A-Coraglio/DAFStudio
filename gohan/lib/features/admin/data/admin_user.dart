/// Fila del listado de usuarios del panel de administración.
class AdminUser {
  final int userId;
  final String username;
  final String email;
  final String displayName;
  final bool isAdmin;
  final DateTime? bannedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;

  const AdminUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.displayName,
    required this.isAdmin,
    required this.bannedAt,
    required this.deletedAt,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    userId: json['user_id'] as int,
    username: json['username'] as String,
    email: json['email'] as String,
    displayName: json['display_name'] as String,
    isAdmin: json['is_admin'] as bool? ?? false,
    bannedAt: _date(json['banned_at']),
    deletedAt: _date(json['deleted_at']),
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.parse(v) : null;

  bool get isBanned => bannedAt != null;
  bool get isDeleted => deletedAt != null;
}
