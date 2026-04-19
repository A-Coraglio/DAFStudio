import 'package:dio/dio.dart';

import '../storage/auth_storage.dart';

/// Attaches the JWT `Authorization` header when one is available, and on 401
/// responses clears the stored token and fires [onUnauthorized] so the session
/// layer can drop the user to /login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.onUnauthorized});

  final Future<void> Function() onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AuthStorage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await AuthStorage.clearToken();
      await onUnauthorized();
    }
    handler.next(err);
  }
}
