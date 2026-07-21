import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted on-device storage for the JWT session tokens.
class AuthStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'token';
  static const _refreshKey = 'refresh_token';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> readToken() => _storage.read(key: _tokenKey);

  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);

  static Future<String?> readRefreshToken() =>
      _storage.read(key: _refreshKey);

  /// Clears the whole session (access + refresh).
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
  }
}
