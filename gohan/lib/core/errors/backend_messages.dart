/// Spanish copy for the backend's business-error messages. AppException
/// bodies arrive as `{type_exception, error, trace}` with `error` mostly in
/// English; this maps the known ones. Unknown messages fall back to the
/// status-based copy in error_messages.dart.
const Map<String, String> _exactMessages = {
  'Game is full': 'El partido está completo.',
  'Position already taken': 'Esa posición ya está ocupada.',
  'Position is out of range': 'Esa posición no existe en este partido.',
  'You already joined this game': 'Ya estás anotado en este partido.',
  'You are not in this game': 'No estás anotado en este partido.',
  'Only participants can report the result':
      'Solo los participantes pueden cargar el resultado.',
  'Only the organizer can perform this action':
      'Solo el organizador puede hacer esto.',
  'Invalid token': 'Tu sesión expiró. Ingresá de nuevo.',
  'Invalid or expired token': 'Tu sesión expiró. Ingresá de nuevo.',
  'You already have an active matchmaking ticket':
      'Ya estás en una búsqueda de partido.',
  'You have no active matchmaking ticket': 'No tenés una búsqueda activa.',
  'Matchmaking ticket not found': 'No tenés una búsqueda activa.',
  'This ticket does not belong to you': 'Esa búsqueda no te pertenece.',
  'Ticket state does not allow this action': 'La búsqueda ya no está activa.',
  'User not found': 'No encontramos ese usuario.',
  'Unauthorized': 'Tu sesión expiró. Ingresá de nuevo.',
  'Forbidden': 'No tenés permiso para hacer esto.',
};

// "Cannot join a 'finished' game" and friends carry the game status inside
// quotes, so they need prefix matching instead of the exact map.
const Map<String, String> _prefixMessages = {
  'Cannot join a': 'Ya no es posible unirse a este partido.',
  'Cannot leave a': 'Ya no es posible salir de este partido.',
  'Cannot report result for a':
      'Ya no se puede cargar el resultado de este partido.',
  "Ticket is '": 'La búsqueda ya no está activa.',
};

/// Translates a backend business message to Spanish. Returns null when the
/// message is unknown AND looks unsafe to show raw (English, too long, or a
/// leaked internal error); short already-Spanish messages pass through.
String? translateBackendMessage(String raw) {
  final exact = _exactMessages[raw];
  if (exact != null) return exact;
  for (final entry in _prefixMessages.entries) {
    if (raw.startsWith(entry.key)) return entry.value;
  }
  final looksInternal = raw.startsWith('Database error') ||
      raw.contains('Exception') ||
      raw.contains('Traceback');
  if (raw.length < 120 && !looksInternal) return raw;
  return null;
}
