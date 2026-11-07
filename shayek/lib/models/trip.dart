enum TripType { beach, business, family, camping, city, other }

class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.type,
    required this.durationDays,
    required this.departureDate,
    required this.travelerCount,
    this.reminderEnabled = false,
    this.reminderTime,
  });

  final String id;
  final String name;
  final TripType type;
  final int durationDays;
  final DateTime departureDate;
  final int travelerCount;
  final bool reminderEnabled;
  final DateTime? reminderTime;

  /// Builds a [Trip] from a raw `trips` table row (see DatabaseService.getTrips).
  factory Trip.fromMap(Map<String, Object?> map) {
    final reminderTime = map['reminder_time'] as String?;
    return Trip(
      id: map['id'] as String,
      name: map['name'] as String,
      type: TripType.values.byName(map['type'] as String),
      durationDays: map['duration_days'] as int,
      departureDate: DateTime.parse(map['departure_date'] as String),
      travelerCount: map['traveler_count'] as int,
      reminderEnabled: (map['reminder_enabled'] as int) != 0,
      reminderTime: reminderTime == null ? null : DateTime.parse(reminderTime),
    );
  }
}
