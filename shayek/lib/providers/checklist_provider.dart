import 'package:flutter/foundation.dart';

import '../models/packing_item.dart';

/// Owns the selected trip's packing items and future checklist CRUD actions.
class ChecklistProvider extends ChangeNotifier {
  final List<PackingItem> _items = [];
  String? _selectedTripId;
  final bool _isLoading = false;
  String? _errorMessage;

  List<PackingItem> get items => List.unmodifiable(_items);
  String? get selectedTripId => _selectedTripId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
}
