// Centralized date formatting so every screen renders times the same way.
// All helpers convert to local time first — backend timestamps may arrive
// naive (server-local) or UTC-marked; toLocal() is a no-op for the former.

const _weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

String _two(int n) => n.toString().padLeft(2, '0');

String _hhmm(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// Schedule of a game: "Hoy 20:00", "Mañana 18:30", "vie 21 18:00",
/// "20/4 18:00" (far future) or "Sin fecha". Past dates read as past:
/// "Ayer 20:00", or "20/4/2026 20:00" — the year makes it obvious.
String formatSchedule(DateTime? at) {
  if (at == null) return 'Sin fecha';
  final d = at.toLocal();
  final now = DateTime.now();
  final diff = DateTime(d.year, d.month, d.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  if (diff == 0) return 'Hoy ${_hhmm(d)}';
  if (diff == 1) return 'Mañana ${_hhmm(d)}';
  if (diff == -1) return 'Ayer ${_hhmm(d)}';
  if (diff > 1 && diff < 7) {
    return '${_weekdays[d.weekday - 1]} ${d.day} ${_hhmm(d)}';
  }
  if (diff < -1) return '${d.day}/${d.month}/${d.year} ${_hhmm(d)}';
  return '${d.day}/${d.month} ${_hhmm(d)}';
}

/// Message bubbles: "14:05" for today, "20/4 14:05" for older messages —
/// a bare hour on an old message would read as sent today.
String formatMessageTime(DateTime at) {
  final d = at.toLocal();
  final now = DateTime.now();
  final sameDay =
      d.year == now.year && d.month == now.month && d.day == now.day;
  return sameDay ? _hhmm(d) : '${d.day}/${d.month} ${_hhmm(d)}';
}

/// Chat list trailing time: "14:05" today, "20/04" otherwise.
String formatListTime(DateTime at) {
  final d = at.toLocal();
  final now = DateTime.now();
  final sameDay =
      d.year == now.year && d.month == now.month && d.day == now.day;
  return sameDay ? _hhmm(d) : '${_two(d.day)}/${_two(d.month)}';
}

/// Full date: "20/04/2026".
String formatFullDate(DateTime at) {
  final d = at.toLocal();
  return '${_two(d.day)}/${_two(d.month)}/${d.year}';
}

/// Day label for chat separators: "Hoy", "Ayer" or "20/4/2026".
String formatDayLabel(DateTime at) {
  final d = at.toLocal();
  final now = DateTime.now();
  final diff = DateTime(now.year, now.month, now.day)
      .difference(DateTime(d.year, d.month, d.day))
      .inDays;
  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Ayer';
  return '${d.day}/${d.month}/${d.year}';
}

/// "Empieza en 45 min" / "Empieza en 3 h" / "Empieza en 2 días" for future
/// schedules; null when there is no date or the game already started.
String? formatCountdown(DateTime? at) {
  if (at == null) return null;
  final diff = at.toLocal().difference(DateTime.now());
  if (diff.isNegative) return null;
  if (diff.inMinutes < 1) return 'Empieza ahora';
  if (diff.inMinutes < 60) return 'Empieza en ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Empieza en ${diff.inHours} h';
  return diff.inDays == 1 ? 'Empieza en 1 día' : 'Empieza en ${diff.inDays} días';
}
