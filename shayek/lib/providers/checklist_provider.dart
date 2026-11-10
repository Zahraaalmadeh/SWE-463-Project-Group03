import 'package:flutter/foundation.dart';

import '../models/packing_item.dart';
import '../models/packing_template.dart';
import '../models/trip.dart';

/// Owns packing items and checklist actions for the selected trip.
///
/// The provider keeps trip lists isolated in memory. Its API is deliberately
/// independent of the screen so a repository can be connected later without
/// changing checklist UI behavior.
class ChecklistProvider extends ChangeNotifier {
  final List<PackingItem> _allItems = [];
  String? _selectedTripId;
  String? _errorMessage;
  final bool _isLoading = false;
  int _idCounter = 0;

  static const categories = <String>[
    'Clothing',
    'Toiletries',
    'Documents',
    'Electronics',
    'Essentials',
    'Activities',
    'Other',
  ];

  List<PackingItem> get items => List.unmodifiable(
    _allItems.where((item) => item.tripId == _selectedTripId),
  );
  String? get selectedTripId => _selectedTripId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCount => items.length;
  int get packedCount => items.where((item) => item.isPacked).length;
  double get progress => totalCount == 0 ? 0 : packedCount / totalCount;

  void selectTrip(String tripId) {
    if (_selectedTripId == tripId) return;
    _selectedTripId = tripId;
    _errorMessage = null;
    notifyListeners();
  }

  /// Replaces the selected trip's list with suggestions tailored to its type,
  /// length, and traveler count.
  void generateChecklist(Trip trip) {
    _selectedTripId = trip.id;
    _allItems.removeWhere((item) => item.tripId == trip.id);
    for (final suggestion in _suggestionsFor(trip)) {
      _allItems.add(
        PackingItem(
          id: _newId(),
          tripId: trip.id,
          name: suggestion.name,
          category: suggestion.category,
          quantity: suggestion.quantity,
          isShared: suggestion.isShared,
        ),
      );
    }

    _errorMessage = null;
    notifyListeners();
  }

  void applyTemplate(Trip trip, PackingTemplate template) {
    _selectedTripId = trip.id;
    _allItems.removeWhere((item) => item.tripId == trip.id);
    _allItems.addAll(
      template.items.map(
        (item) => PackingItem(
          id: _newId(),
          tripId: trip.id,
          name: item.name,
          category: item.category,
          quantity: item.quantity,
        ),
      ),
    );
    _errorMessage = null;
    notifyListeners();
  }

  PackingItem addItem({
    required String name,
    required String category,
    int quantity = 1,
    bool isShared = false,
  }) {
    final tripId = _selectedTripId;
    if (tripId == null) {
      throw StateError('Select a trip before adding packing items.');
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Item name cannot be empty.');
    }
    final item = PackingItem(
      id: _newId(),
      tripId: tripId,
      name: trimmedName,
      category: _validCategory(category),
      quantity: quantity < 1 ? 1 : quantity,
      isShared: isShared,
    );
    _allItems.add(item);
    notifyListeners();
    return item;
  }

  void updateItem(PackingItem updatedItem) {
    final index = _allItems.indexWhere(
      (item) => item.id == updatedItem.id && item.tripId == updatedItem.tripId,
    );
    if (index < 0) return;
    final name = updatedItem.name.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(
        updatedItem.name,
        'name',
        'Item name cannot be empty.',
      );
    }
    _allItems[index] = PackingItem(
      id: updatedItem.id,
      tripId: updatedItem.tripId,
      travelerId: updatedItem.travelerId,
      name: name,
      category: _validCategory(updatedItem.category),
      quantity: updatedItem.quantity < 1 ? 1 : updatedItem.quantity,
      isPacked: updatedItem.isPacked,
      isShared: updatedItem.isShared,
      isReturnItem: updatedItem.isReturnItem,
    );
    notifyListeners();
  }

  void togglePacked(String itemId) {
    final index = _allItems.indexWhere(
      (item) => item.id == itemId && item.tripId == _selectedTripId,
    );
    if (index < 0) return;
    final item = _allItems[index];
    _allItems[index] = _copy(item, isPacked: !item.isPacked);
    notifyListeners();
  }

  void removeItem(String itemId) {
    final originalLength = _allItems.length;
    _allItems.removeWhere(
      (item) => item.id == itemId && item.tripId == _selectedTripId,
    );
    if (_allItems.length != originalLength) notifyListeners();
  }

  void removePackedItems() {
    final originalLength = _allItems.length;
    _allItems.removeWhere(
      (item) => item.tripId == _selectedTripId && item.isPacked,
    );
    if (_allItems.length != originalLength) notifyListeners();
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${_idCounter++}';

  String _validCategory(String category) =>
      categories.contains(category) ? category : 'Other';

  PackingItem _copy(PackingItem item, {required bool isPacked}) => PackingItem(
    id: item.id,
    tripId: item.tripId,
    travelerId: item.travelerId,
    name: item.name,
    category: item.category,
    quantity: item.quantity,
    isPacked: isPacked,
    isShared: item.isShared,
    isReturnItem: item.isReturnItem,
  );

  List<_Suggestion> _suggestionsFor(Trip trip) {
    final days = trip.durationDays.clamp(1, 60).toInt();
    final travelers = trip.travelerCount.clamp(1, 12).toInt();
    final suggestions = <_Suggestion>[
      _Suggestion('Tops', 'Clothing', days * travelers),
      _Suggestion('Bottoms', 'Clothing', ((days + 1) ~/ 2) * travelers),
      _Suggestion('Underwear', 'Clothing', days * travelers),
      _Suggestion('Socks', 'Clothing', days * travelers),
      _Suggestion('Sleepwear', 'Clothing', travelers),
      _Suggestion('Comfortable shoes', 'Clothing', 1),
      _Suggestion('Toothbrushes', 'Toiletries', travelers),
      _Suggestion('Toothpaste', 'Toiletries', 1),
      _Suggestion('Shampoo and conditioner', 'Toiletries', 1),
      _Suggestion('Personal medication', 'Toiletries', travelers),
      _Suggestion('Phone chargers', 'Electronics', travelers),
      _Suggestion('Headphones', 'Electronics', travelers),
      _Suggestion('Phone', 'Essentials', travelers),
      _Suggestion('Wallet', 'Essentials', travelers),
      _Suggestion('Reusable water bottle', 'Essentials', travelers),
      _Suggestion('Sunglasses', 'Essentials', travelers),
      _Suggestion('Keys', 'Essentials', 1),
      _Suggestion('Passport or photo ID', 'Documents', travelers),
      _Suggestion('Tickets and reservations', 'Documents', 1, isShared: true),
    ];

    switch (trip.type) {
      case TripType.beach:
        suggestions.addAll([
          _Suggestion('Swimsuit', 'Clothing', travelers),
          _Suggestion('Beach towel', 'Activities', travelers),
          _Suggestion('Sunscreen', 'Toiletries', 1),
          _Suggestion('Sandals', 'Clothing', travelers),
        ]);
      case TripType.business:
        suggestions.addAll([
          _Suggestion('Business outfits', 'Clothing', days * travelers),
          _Suggestion('Laptop and accessories', 'Electronics', travelers),
          _Suggestion('Work documents', 'Documents', 1, isShared: true),
        ]);
      case TripType.family:
        suggestions.addAll([
          _Suggestion('First-aid kit', 'Essentials', 1, isShared: true),
          _Suggestion('Snacks for the trip', 'Activities', 1, isShared: true),
          _Suggestion('Entertainment for the journey', 'Activities', travelers),
        ]);
      case TripType.camping:
        suggestions.addAll([
          _Suggestion('Camping tent', 'Activities', 1, isShared: true),
          _Suggestion('Sleeping bag', 'Activities', travelers),
          _Suggestion('Flashlight', 'Activities', 1, isShared: true),
          _Suggestion('Insect repellent', 'Toiletries', 1),
        ]);
      case TripType.city:
        suggestions.addAll([
          _Suggestion('Day bag', 'Activities', travelers),
          _Suggestion('Portable power bank', 'Electronics', travelers),
          _Suggestion('Light jacket', 'Clothing', travelers),
        ]);
      case TripType.other:
        suggestions.addAll([
          _Suggestion('Weather-appropriate jacket', 'Clothing', travelers),
          _Suggestion('Portable power bank', 'Electronics', travelers),
        ]);
    }

    return suggestions;
  }
}

class _Suggestion {
  const _Suggestion(
    this.name,
    this.category,
    this.quantity, {
    this.isShared = false,
  });

  final String name;
  final String category;
  final int quantity;
  final bool isShared;
}
