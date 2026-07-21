import 'package:dio/dio.dart';

/// Unwraps `res.data` sin el null-check crash de `res.data!`.
///
/// Si el backend devolviera 200 con un body vacío o no parseable, `res.data!`
/// tiraba un TypeError crudo; esto lo convierte en un DioException que el
/// pipeline de errores (`friendlyErrorMessage` / `ErrorView`) ya sabe mostrar.
T requireData<T>(Response<T> res) {
  final data = res.data;
  if (data != null) return data;
  throw DioException(
    requestOptions: res.requestOptions,
    response: res,
    type: DioExceptionType.badResponse,
    message: 'El servidor devolvió una respuesta vacía',
  );
}
