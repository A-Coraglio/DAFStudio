/// Matches the backend `ClubOutputDTO` returned by `/api/clubs/`.
class Club {
  final int id;
  final int ownerId;
  final String name;
  final String address;
  final String city;
  final String? description;

  const Club({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.city,
    this.description,
  });

  factory Club.fromJson(Map<String, dynamic> json) => Club(
    id: json['id'] as int,
    ownerId: json['owner_id'] as int,
    name: json['name'] as String,
    address: json['address'] as String,
    city: json['city'] as String,
    description: json['description'] as String?,
  );
}
