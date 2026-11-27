import 'package:shayek/database/traveler_repository.dart';
import 'package:shayek/models/traveler.dart';

/// Test double that keeps family members in memory.
class InMemoryTravelerRepository implements TravelerRepository {
  final rows = <Traveler>[];

  @override
  Future<List<Traveler>> getTravelers(String tripId) async =>
      rows.where((traveler) => traveler.tripId == tripId).toList();

  @override
  Future<void> insertTraveler(Traveler traveler) async => rows.add(traveler);

  @override
  Future<void> deleteTraveler(String travelerId) async =>
      rows.removeWhere((traveler) => traveler.id == travelerId);
}
