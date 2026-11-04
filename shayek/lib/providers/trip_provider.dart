import 'package:flutter/foundation.dart';

import '../models/trip.dart';

/// Owns trip records and will coordinate trip CRUD with persistence.
class TripProvider extends ChangeNotifier {
  final List<Trip> _trips = [];
  final bool _isLoading = false;
  String? _errorMessage;

  List<Trip> get trips => List.unmodifiable(_trips);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
}
