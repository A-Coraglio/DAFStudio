import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted on-device storage for the JWT access token.
class AuthStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'token';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> readToken() => _storage.read(key: _tokenKey);

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
