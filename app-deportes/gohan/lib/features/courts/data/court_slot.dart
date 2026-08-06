/// Turno de una cancha de club (court_slot).
class CourtSlot {
  final int id;
  final int courtId;
  final DateTime start;
  final DateTime end;
  final String status; // free | booked | blocked

  /// Player que reservó (para saber si el turno es mío).
  final int? bookedByPlayerId;

  /// Nombre del que reservó — solo lo recibe quien administra la cancha.
  final String? bookedByName;

  /// Contexto — solo en /courts/my-bookings/.
  final String? courtName;
  final String? clubName;
  final int? sportId;

  const CourtSlot({
    required this.id,
    required this.courtId,
    required this.start,
    required this.end,
    required this.status,
    required this.bookedByPlayerId,
    required this.bookedByName,
    required this.courtName,
    required this.clubName,
    required this.sportId,
  });

  factory CourtSlot.fromJson(Map<String, dynamic> json) => CourtSlot(
    id: json['id'] as int,
    courtId: json['court_id'] as int,
    start: DateTime.parse(json['start_time'] as String),
    end: DateTime.parse(json['end_time'] as String),
    status: json['status'] as String,
    bookedByPlayerId: json['booked_by_player_id'] as int?,
    bookedByName: json['booked_by_name'] as String?,
    courtName: json['court_name'] as String?,
    clubName: json['club_name'] as String?,
    sportId: json['sport_id'] as int?,
  );

  bool get isFree => status == 'free';
  bool get isBooked => status == 'booked';
  bool get isBlocked => status == 'blocked';
}
