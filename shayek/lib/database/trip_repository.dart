import 'package:sqflite/sqflite.dart';

import '../models/trip.dart';
import 'database_service.dart';

/// Persistence boundary for trips, so providers never talk to SQLite directly
/// and tests can substitute an in-memory implementation.
abstract interface class TripRepository {
  Future<void> insertTrip(Trip trip);

  /// Returns every saved trip, soonest departure first.
  Future<List<Trip>> getTrips();

  Future<Trip?> getTrip(String id);
}

/// Stores trips in the `trips` table created by [DatabaseService].
class SqfliteTripRepository implements TripRepository {
  SqfliteTripRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  static const _table = 'trips';

  final DatabaseService _databaseService;

  @override
  Future<void> insertTrip(Trip trip) async {
    final database = await _databaseService.database;
    await database.insert(
      _table,
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<List<Trip>> getTrips() async {
    // DatabaseService owns the query (soonest departure first); this layer
    // only maps the raw rows to models.
    final rows = await _databaseService.getTrips();
    return rows.map(Trip.fromMap).toList();
  }

  @override
  Future<Trip?> getTrip(String id) async {
    final database = await _databaseService.database;
    final rows = await database.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Trip.fromMap(rows.first);
  }
}
