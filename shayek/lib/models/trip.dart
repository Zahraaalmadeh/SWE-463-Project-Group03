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
}
