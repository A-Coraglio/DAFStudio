import 'package:dio/dio.dart';

import 'auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<LoginResponse> login(LoginRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login/',
      data: req.toJson(),
    );
    return LoginResponse.fromJson(res.data!);
  }

  Future<UserAccount> register(RegisterRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register/',
      data: req.toJson(),
    );
    return UserAccount.fromJson(res.data!);
  }

  /// Exchanges a Google id_token (obtained by the native Google Sign-In SDK)
  /// for our own JWT. Creates the user on first sign-in.
  Future<LoginResponse> loginWithGoogle(GoogleLoginRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/google/',
      data: req.toJson(),
    );
    return LoginResponse.fromJson(res.data!);
  }
}
