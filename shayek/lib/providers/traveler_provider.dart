import 'package:flutter/foundation.dart';

import '../database/traveler_repository.dart';
import '../models/traveler.dart';

class TravelerProvider extends ChangeNotifier {
  TravelerProvider({TravelerRepository? repository})
    : _repository = repository ?? SqfliteTravelerRepository();

  final TravelerRepository _repository;
  final List<Traveler> _travelers = [];
  String? _selectedTripId;
  bool _isLoading = false;
  String? _errorMessage;

  List<Traveler> get travelers => List.unmodifiable(_travelers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTravelers(String tripId) async {
    _selectedTripId = tripId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final saved = await _repository.getTravelers(tripId);
      _travelers
        ..clear()
        ..addAll(saved);
    } catch (error) {
      _errorMessage = 'Could not load family members. Please try again.';
      debugPrint('Failed to load travelers: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTraveler(String name) async {
    final tripId = _selectedTripId;
    final trimmedName = name.trim();
    if (tripId == null) throw StateError('Select a trip first.');
    if (trimmedName.isEmpty) throw ArgumentError('Name cannot be empty.');

    final traveler = Traveler(
      id: 'traveler-${DateTime.now().microsecondsSinceEpoch}',
      tripId: tripId,
      name: trimmedName,
    );
    try {
      await _repository.insertTraveler(traveler);
      _travelers.add(traveler);
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Could not save family member. Please try again.';
      debugPrint('Failed to save traveler: $error');
      notifyListeners();
    }
  }

  Future<void> removeTraveler(String travelerId) async {
    try {
      await _repository.deleteTraveler(travelerId);
      _travelers.removeWhere((traveler) => traveler.id == travelerId);
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Could not remove family member. Please try again.';
      debugPrint('Failed to delete traveler: $error');
      notifyListeners();
    }
  }
}
