import 'package:shayek/database/trip_repository.dart';
import 'package:shayek/models/trip.dart';

/// Test double that stores trips as table rows in memory, exercising the same
/// [Trip.toMap] / [Trip.fromMap] round trip as the SQLite repository.
class InMemoryTripRepository implements TripRepository {
  final rows = <Map<String, Object?>>[];

  /// When set, every call throws this error to simulate a database failure.
  Object? failWith;

  @override
  Future<void> insertTrip(Trip trip) async {
    _maybeFail();
    if (rows.any((row) => row['id'] == trip.id)) {
      throw StateError('Duplicate trip id ${trip.id}');
    }
    rows.add(trip.toMap());
  }

  @override
  Future<List<Trip>> getTrips() async {
    _maybeFail();
    final trips = rows.map(Trip.fromMap).toList()
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));
    return trips;
  }

  @override
  Future<Trip?> getTrip(String id) async {
    _maybeFail();
    for (final row in rows) {
      if (row['id'] == id) return Trip.fromMap(row);
    }
    return null;
  }

  void _maybeFail() {
    final error = failWith;
    if (error != null) throw error;
  }
}
