/// Matches the backend `CourtOutputDTO` returned by `/api/courts/`.
///
/// A court is either a club court (club_id set, owner_id null) or a private
/// one (owner_id set, club_id null). The XOR is enforced DB-side.
class Court {
  final int id;
  final int? clubId;
  final int? ownerId;
  final int sportId;
  final String name;
  final double pricePerHour;
  final bool isIndoor;
  final double? lat;
  final double? lon;

  const Court({
    required this.id,
    required this.clubId,
    required this.ownerId,
    required this.sportId,
    required this.name,
    required this.pricePerHour,
    required this.isIndoor,
    required this.lat,
    required this.lon,
  });

  factory Court.fromJson(Map<String, dynamic> json) => Court(
        id: json['id'] as int,
        clubId: json['club_id'] as int?,
        ownerId: json['owner_id'] as int?,
        sportId: json['sport_id'] as int,
        name: json['name'] as String,
        pricePerHour: (json['price_per_hour'] as num).toDouble(),
        isIndoor: json['is_indoor'] as bool,
        lat: (json['lat'] as num?)?.toDouble(),
        lon: (json['lon'] as num?)?.toDouble(),
      );

  bool get isPrivate => ownerId != null;
}
