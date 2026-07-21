/// The auth account (auth_user) behind the player — matches
/// `GET /api/auth/users/{id}/`. Distinct from PlayerProfile (player table).
class UserAccount {
  final int id;
  final String username;
  final String email;
  final bool hasPassword;
  final double? homeLat;
  final double? homeLon;

  const UserAccount({
    required this.id,
    required this.username,
    required this.email,
    required this.hasPassword,
    required this.homeLat,
    required this.homeLon,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
    id: json['id'] as int,
    username: json['username'] as String,
    email: json['email'] as String,
    hasPassword: json['has_password'] as bool? ?? true,
    homeLat: (json['home_lat'] as num?)?.toDouble(),
    homeLon: (json['home_lon'] as num?)?.toDouble(),
  );

  bool get hasHomeLocation => homeLat != null && homeLon != null;
}
