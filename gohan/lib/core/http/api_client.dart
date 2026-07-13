import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';

/// Builds the app-wide Dio client, pre-configured with the backend base URL
/// and the auth interceptor.
Dio buildApiClient({required Future<void> Function() onUnauthorized}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      // Anything non-2xx raises a DioException; the caller decides what to
      // do based on err.response.statusCode.
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );
  dio.interceptors.add(AuthInterceptor(onUnauthorized: onUnauthorized));
  return dio;
}

/// Extracts a human-readable error from a DioException. The backend returns
/// either `{detail: ...}` (FastAPI HTTPException) or `{error: ..., type_exception, trace}`
/// (our custom middleware).
String dioErrorMessage(DioException err) {
  final data = err.response?.data;
  if (data is Map) {
    final detail = data['detail'];
    if (detail is String) return detail;
    final error = data['error'];
    if (error is String) return error;
  }
  return err.message ?? 'Error de red';
}
