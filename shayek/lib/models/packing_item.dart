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
}
