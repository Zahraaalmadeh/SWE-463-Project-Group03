import 'package:flutter/foundation.dart';

import '../models/packing_item.dart';
import '../models/trip.dart';

/// Owns the selected trip's packing items and future checklist CRUD actions.
class ChecklistProvider extends ChangeNotifier {
  // items/isLoading/errorMessage are placeholders for the Checklist team:
  // nothing populates them yet, since generating/loading packing items is
  // out of scope for Home. Only selectedTrip is wired up so far.
  final List<PackingItem> _items = [];
  Trip? _selectedTrip;
  final bool _isLoading = false;
  String? _errorMessage;

  List<PackingItem> get items => List.unmodifiable(_items);
  Trip? get selectedTrip => _selectedTrip;
  String? get selectedTripId => _selectedTrip?.id;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Called from Home when a trip card is tapped, so Checklist knows which
  /// trip to open without Home passing data through route arguments.
  void selectTrip(Trip trip) {
    _selectedTrip = trip;
    notifyListeners();
  }
}
