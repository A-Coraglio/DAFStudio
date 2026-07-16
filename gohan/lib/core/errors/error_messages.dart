import 'package:dio/dio.dart';

import 'backend_messages.dart';

/// Single source of truth to turn any error into a short Spanish message the
/// user can act on. Screens must never format an error by hand: use this (or
/// ErrorView / showErrorSnack, which delegate here).
String friendlyErrorMessage(Object? error) {
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout =>
        'No se pudo conectar al servidor. Revisá tu conexión.',
      DioExceptionType.receiveTimeout =>
        'El servidor tardó demasiado en responder. Probá de nuevo.',
      DioExceptionType.cancel => 'Operación cancelada.',
      DioExceptionType.badResponse => _fromResponse(error.response),
      _ => 'Algo salió mal. Probá de nuevo.',
    };
  }
  return 'Algo salió mal. Probá de nuevo.';
}

String _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode ?? 0;
  final data = response?.data;
  if (data is Map) {
    // Never surface leaked internals, no matter what the message says.
    if (data['type_exception'] != 'DatabaseException') {
      final raw = data['error'] ?? data['detail'];
      if (raw is String) {
        final translated = translateBackendMessage(raw);
        if (translated != null) return translated;
      }
    }
  }
  return switch (status) {
    401 => 'Tu sesión expiró. Ingresá de nuevo.',
    403 => 'No tenés permiso para hacer esto.',
    404 => 'No encontramos lo que buscabas.',
    409 => 'La acción ya no es válida. Actualizá e intentá de nuevo.',
    422 => 'Revisá los datos ingresados.',
    >= 500 => 'Algo salió mal en el servidor. Probá más tarde.',
    _ => 'Algo salió mal. Probá de nuevo.',
  };
}
