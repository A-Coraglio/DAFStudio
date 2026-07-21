import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/auth_storage.dart';

/// Exchanges the stored refresh token for a new access+refresh pair.
///
/// Single-flight: if five requests hit a 401 at the same time, only ONE
/// refresh goes to the backend and the rest await the same future. Uses a
/// bare Dio (no interceptors) so a failing refresh can't recurse.
class TokenRefresher {
  static Future<String?>? _inFlight;

  static Future<String?> refresh() =>
      _inFlight ??= _doRefresh().whenComplete(() => _inFlight = null);

  static Future<String?> _doRefresh() async {
    final refreshToken = await AuthStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final res = await Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl))
          .post<Map<String, dynamic>>(
        '/api/auth/refresh/',
        data: {'refresh_token': refreshToken},
      );
      final access = res.data?['access_token'] as String?;
      if (access == null || access.isEmpty) return null;
      await AuthStorage.saveToken(access);
      final rotated = res.data?['refresh_token'] as String?;
      if (rotated != null && rotated.isNotEmpty) {
        await AuthStorage.saveRefreshToken(rotated);
      }
      return access;
    } catch (_) {
      return null; // expired/invalid refresh → caller logs the session out
    }
  }
}
