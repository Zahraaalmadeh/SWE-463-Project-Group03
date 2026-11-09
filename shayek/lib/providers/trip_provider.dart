import 'package:flutter/foundation.dart';

import '../database/database_service.dart';
import '../models/trip.dart';

/// Owns trip records and will coordinate trip CRUD with persistence.
class TripProvider extends ChangeNotifier {
  final List<Trip> _trips = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Trip> get trips => List.unmodifiable(_trips);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads every trip from the local database. Screens call this once (e.g.
  /// from initState) and otherwise only read `trips`/`isLoading`/`errorMessage`
  /// through this provider, never through DatabaseService directly.
  Future<void> loadTrips() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rows = await DatabaseService.instance.getTrips();
      _trips
        ..clear()
        ..addAll(rows.map(Trip.fromMap));
    } catch (error) {
      _errorMessage = 'Could not load trips. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
