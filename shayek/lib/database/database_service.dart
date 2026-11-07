import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens and creates Shayek's local SQLite database.
///
/// Providers will use this service in later phases; screens should never access
/// SQLite directly.
class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  static const _databaseName = 'shayek.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final existingDatabase = _database;
    if (existingDatabase != null) {
      return existingDatabase;
    }

    final databasesPath = await getDatabasesPath();
    final databasePath = join(databasesPath, _databaseName);
    final database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createTables,
    );
    _database = database;
    return database;
  }

  /// Returns every row of the `trips` table, soonest departure first.
  /// Providers turn these raw rows into `Trip` objects; this service stays
  /// unaware of the domain models.
  Future<List<Map<String, Object?>>> getTrips() async {
    final db = await database;
    return db.query('trips', orderBy: 'departure_date ASC');
  }

  Future<void> _createTables(Database database, int version) async {
    await database.execute('''
      CREATE TABLE trips(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        duration_days INTEGER NOT NULL,
        departure_date TEXT NOT NULL,
        traveler_count INTEGER NOT NULL,
        reminder_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_time TEXT
      )
    ''');
    await database.execute('''
      CREATE TABLE travelers(
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');
    await database.execute('''
      CREATE TABLE packing_items(
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        traveler_id TEXT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        is_packed INTEGER NOT NULL DEFAULT 0,
        is_shared INTEGER NOT NULL DEFAULT 0,
        is_return_item INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
        FOREIGN KEY (traveler_id) REFERENCES travelers(id) ON DELETE SET NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE templates(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE template_items(
        id TEXT PRIMARY KEY,
        template_id TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
      )
    ''');
  }
}
