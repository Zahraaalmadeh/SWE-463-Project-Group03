import 'package:sqflite/sqflite.dart';

import '../models/packing_item.dart';
import 'database_service.dart';

abstract interface class PackingItemRepository {
  Future<List<PackingItem>> getItems(String tripId);
  Future<void> insertItem(PackingItem item);
  Future<void> updateItem(PackingItem item);
  Future<void> deleteItem(String itemId);
  Future<void> deleteItems(List<String> itemIds);
  Future<void> replaceItems(String tripId, List<PackingItem> items);
}

class SqflitePackingItemRepository implements PackingItemRepository {
  SqflitePackingItemRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  @override
  Future<List<PackingItem>> getItems(String tripId) async {
    final database = await _databaseService.database;
    final rows = await database.query(
      'packing_items',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'id ASC',
    );
    return rows.map(PackingItem.fromMap).toList();
  }

  @override
  Future<void> insertItem(PackingItem item) async {
    final database = await _databaseService.database;
    await database.insert(
      'packing_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateItem(PackingItem item) => insertItem(item);

  @override
  Future<void> deleteItem(String itemId) async {
    final database = await _databaseService.database;
    await database.delete(
      'packing_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  @override
  Future<void> deleteItems(List<String> itemIds) async {
    if (itemIds.isEmpty) return;
    final database = await _databaseService.database;
    await database.delete(
      'packing_items',
      where: 'id IN (${List.filled(itemIds.length, '?').join(',')})',
      whereArgs: itemIds,
    );
  }

  @override
  Future<void> replaceItems(String tripId, List<PackingItem> items) async {
    final database = await _databaseService.database;
    await database.transaction((transaction) async {
      await transaction.delete(
        'packing_items',
        where: 'trip_id = ?',
        whereArgs: [tripId],
      );
      for (final item in items) {
        await transaction.insert(
          'packing_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
