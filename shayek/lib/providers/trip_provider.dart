import 'dart:math';

import 'package:flutter/foundation.dart';

import '../database/trip_repository.dart';
import '../models/trip.dart';

/// Owns trip records and coordinates trip CRUD with persistence.
class TripProvider extends ChangeNotifier {
  TripProvider({TripRepository? repository})
    : _repository = repository ?? SqfliteTripRepository();

  final TripRepository _repository;
  final List<Trip> _trips = [];
  final _random = Random();
  bool _isLoading = false;
  String? _errorMessage;

  List<Trip> get trips => List.unmodifiable(_trips);
  bool get isLoading => _isLoading;

  /// Why the last [loadTrips] failed, or null. Home shows this in place of
  /// the trip list, so only load failures set it; [createTrip] reports save
  /// failures to its caller by throwing instead.
  String? get errorMessage => _errorMessage;

  /// Returns the loaded trip with [id], or null when it is not in memory.
  Trip? tripById(String id) {
    for (final trip in _trips) {
      if (trip.id == id) return trip;
    }
    return null;
  }

  /// Loads every trip from the local database. Screens call this once (e.g.
  /// from initState) and otherwise only read `trips`/`isLoading`/`errorMessage`
  /// through this provider, never through DatabaseService directly.
  Future<void> loadTrips() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final saved = await _repository.getTrips();
      _trips
        ..clear()
        ..addAll(saved);
    } catch (error) {
      _errorMessage = 'Could not load trips. Please try again.';
      debugPrint('Failed to load trips: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves a new trip and adds it to [trips], so listeners such as Home show
  /// it immediately.
  ///
  /// Throws if the input is invalid or the trip could not be saved; in that
  /// case [trips] and [errorMessage] are left unchanged.
  Future<Trip> createTrip({
    required String name,
    required TripType type,
    required int durationDays,
    required DateTime departureDate,
    required int travelerCount,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Trip name cannot be empty.');
    }
    if (durationDays < 1) {
      throw RangeError.value(
        durationDays,
        'durationDays',
        'Must be at least 1.',
      );
    }
    if (travelerCount < 1) {
      throw RangeError.value(
        travelerCount,
        'travelerCount',
        'Must be at least 1.',
      );
    }

    final trip = Trip(
      id: _newId(),
      name: trimmedName,
      type: type,
      durationDays: durationDays,
      departureDate: DateTime(
        departureDate.year,
        departureDate.month,
        departureDate.day,
      ),
      travelerCount: travelerCount,
    );

    await _repository.insertTrip(trip);

    _trips
      ..add(trip)
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));
    notifyListeners();
    return trip;
  }

  String _newId() {
    final suffix = _random
        .nextInt(0x7fffffff)
        .toRadixString(16)
        .padLeft(8, '0');
    return 'trip-${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }
}
