class PackingItem {
  const PackingItem({
    required this.id,
    required this.tripId,
    required this.name,
    required this.category,
    this.travelerId,
    this.quantity = 1,
    this.isPacked = false,
    this.isShared = false,
    this.isReturnItem = false,
  });

  final String id;
  final String tripId;
  final String? travelerId;
  final String name;
  final String category;
  final int quantity;
  final bool isPacked;
  final bool isShared;
  final bool isReturnItem;

  Map<String, Object?> toMap() => {
    'id': id,
    'trip_id': tripId,
    'traveler_id': travelerId,
    'name': name,
    'category': category,
    'quantity': quantity,
    'is_packed': isPacked ? 1 : 0,
    'is_shared': isShared ? 1 : 0,
    'is_return_item': isReturnItem ? 1 : 0,
  };

  factory PackingItem.fromMap(Map<String, Object?> row) => PackingItem(
    id: row['id'] as String,
    tripId: row['trip_id'] as String,
    travelerId: row['traveler_id'] as String?,
    name: row['name'] as String,
    category: row['category'] as String,
    quantity: row['quantity'] as int,
    isPacked: (row['is_packed'] as int? ?? 0) == 1,
    isShared: (row['is_shared'] as int? ?? 0) == 1,
    isReturnItem: (row['is_return_item'] as int? ?? 0) == 1,
  );
}
