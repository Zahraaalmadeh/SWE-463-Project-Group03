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

  /// Builds a [Trip] from a raw `trips` table row (see DatabaseService.getTrips).
  ///
  /// An unrecognised stored type falls back to [TripType.other] instead of
  /// throwing, so one bad row cannot break the whole trip list.
  factory Trip.fromMap(Map<String, Object?> map) {
    final typeName = map['type']! as String;
    final reminderTime = map['reminder_time'] as String?;
    return Trip(
      id: map['id']! as String,
      name: map['name']! as String,
      type: TripType.values.firstWhere(
        (type) => type.name == typeName,
        orElse: () => TripType.other,
      ),
      durationDays: map['duration_days']! as int,
      departureDate: DateTime.parse(map['departure_date']! as String),
      travelerCount: map['traveler_count']! as int,
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) != 0,
      reminderTime: reminderTime == null ? null : DateTime.parse(reminderTime),
    );
  }

  final String id;
  final String name;
  final TripType type;
  final int durationDays;
  final DateTime departureDate;
  final int travelerCount;
  final bool reminderEnabled;
  final DateTime? reminderTime;

  /// Converts the trip to a row of the `trips` table.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'duration_days': durationDays,
      'departure_date': departureDate.toIso8601String(),
      'traveler_count': travelerCount,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_time': reminderTime?.toIso8601String(),
    };
  }
}
