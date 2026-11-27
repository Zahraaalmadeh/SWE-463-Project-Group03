import 'package:sqflite/sqflite.dart';

import '../models/traveler.dart';
import 'database_service.dart';

abstract interface class TravelerRepository {
  Future<List<Traveler>> getTravelers(String tripId);
  Future<void> insertTraveler(Traveler traveler);
  Future<void> deleteTraveler(String travelerId);
}

class SqfliteTravelerRepository implements TravelerRepository {
  SqfliteTravelerRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  @override
  Future<List<Traveler>> getTravelers(String tripId) async {
    final database = await _databaseService.database;
    final rows = await database.query(
      'travelers',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'name ASC',
    );
    return rows.map(Traveler.fromMap).toList();
  }

  @override
  Future<void> insertTraveler(Traveler traveler) async {
    final database = await _databaseService.database;
    await database.insert(
      'travelers',
      traveler.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTraveler(String travelerId) async {
    final database = await _databaseService.database;
    await database.delete(
      'travelers',
      where: 'id = ?',
      whereArgs: [travelerId],
    );
  }
}
