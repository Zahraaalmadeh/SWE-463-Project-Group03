import 'package:shayek/database/packing_item_repository.dart';
import 'package:shayek/models/packing_item.dart';

class InMemoryPackingItemRepository implements PackingItemRepository {
  final Map<String, PackingItem> rows = {};

  @override
  Future<void> deleteItem(String itemId) async {
    rows.remove(itemId);
  }

  @override
  Future<void> deleteItems(List<String> itemIds) async {
    for (final itemId in itemIds) {
      rows.remove(itemId);
    }
  }

  @override
  Future<List<PackingItem>> getItems(String tripId) async =>
      rows.values.where((item) => item.tripId == tripId).toList();

  @override
  Future<void> insertItem(PackingItem item) async {
    rows[item.id] = item;
  }

  @override
  Future<void> replaceItems(String tripId, List<PackingItem> items) async {
    rows.removeWhere((_, item) => item.tripId == tripId);
    for (final item in items) {
      rows[item.id] = item;
    }
  }

  @override
  Future<void> updateItem(PackingItem item) async {
    rows[item.id] = item;
  }
}
