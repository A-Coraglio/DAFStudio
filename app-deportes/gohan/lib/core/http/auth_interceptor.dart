import 'package:dio/dio.dart';

import '../storage/auth_storage.dart';
import 'token_refresher.dart';

/// Attaches the JWT `Authorization` header, and on a 401 tries a silent
/// token refresh + one retry of the failed request. Only when the refresh
/// itself fails does it clear the session and fire [onUnauthorized].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.onUnauthorized});

  final Future<void> Function() onUnauthorized;

  /// Set by [buildApiClient] right after construction — used to replay the
  /// original request once the token was refreshed.
  late final Dio dio;

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
    final status = err.response?.statusCode;
    final opts = err.requestOptions;
    // Auth endpoints 401 for their own reasons (bad password, bad refresh) —
    // never treat those as an expired session. `retried` breaks the loop if
    // the replayed request 401s again.
    final canRefresh = status == 401 &&
        !opts.path.contains('/api/auth/') &&
        opts.extra['retried'] != true;
    if (!canRefresh) {
      if (status == 401 && !opts.path.contains('/api/auth/')) {
        await AuthStorage.clearToken();
        await onUnauthorized();
      }
      return handler.next(err);
    }

    final newToken = await TokenRefresher.refresh();
    if (newToken == null) {
      await AuthStorage.clearToken();
      await onUnauthorized();
      return handler.next(err);
    }
    try {
      opts.headers['Authorization'] = 'Bearer $newToken';
      opts.extra['retried'] = true;
      final response = await dio.fetch<dynamic>(opts);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
