/// El backend emite los mensajes de negocio directamente en español
/// (sweep 2026-07-21), así que ya no hace falta el mapa inglés→español que
/// vivía acá. Queda solo el passthrough con filtro: mensajes cortos y
/// no-internos se muestran tal cual; cualquier cosa que parezca un error
/// interno cae al copy por status de error_messages.dart.
///
/// Si alguna vez el backend vuelve a emitir un mensaje en inglés, la regla
/// sigue siendo traducirlo EN EL BACKEND, no revivir el mapa.
String? translateBackendMessage(String raw) {
  final looksInternal = raw.startsWith('Database error') ||
      raw.contains('Exception') ||
      raw.contains('Traceback');
  if (raw.length < 120 && !looksInternal) return raw;
  return null;
}
