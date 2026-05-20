/// Input for `POST /api/auth/login/`.
class LoginRequest {
  final String email;
  final String password;
  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

/// Input for `POST /api/auth/google/`.
class GoogleLoginRequest {
  final String idToken;
  const GoogleLoginRequest({required this.idToken});

  Map<String, dynamic> toJson() => {'id_token': idToken};
}

/// Response of `POST /api/auth/login/`.
class LoginResponse {
  final String accessToken;
  final String tokenType;
  const LoginResponse({required this.accessToken, required this.tokenType});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token'] as String,
        tokenType: (json['token_type'] as String?) ?? 'bearer',
      );
}

/// Input for `POST /api/auth/register/`.
///
/// Register is intentionally minimal — profile details (name, surname,
/// favorite sport, level) are collected later via the onboarding flow
/// against `PUT /api/players/me/`.
class RegisterRequest {
  final String username;
  final String email;
  final String password;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
      };
}

/// What the backend returns for a user (public shape, no password).
class UserAccount {
  final int id;
  final String username;
  final String email;
  const UserAccount({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
      );
}
