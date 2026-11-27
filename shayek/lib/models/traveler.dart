class Traveler {
  const Traveler({required this.id, required this.tripId, required this.name});

  final String id;
  final String tripId;
  final String name;

  Map<String, Object?> toMap() => {'id': id, 'trip_id': tripId, 'name': name};

  factory Traveler.fromMap(Map<String, Object?> row) => Traveler(
    id: row['id'] as String,
    tripId: row['trip_id'] as String,
    name: row['name'] as String,
  );
}
