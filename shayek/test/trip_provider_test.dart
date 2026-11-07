import 'package:flutter_test/flutter_test.dart';
import 'package:shayek/models/trip.dart';
import 'package:shayek/providers/trip_provider.dart';

import 'fakes/in_memory_trip_repository.dart';

void main() {
  group('Trip map conversion', () {
    test('round-trips through a trips table row', () {
      final trip = Trip(
        id: 'trip-1',
        name: 'Summer in Santorini',
        type: TripType.beach,
        durationDays: 5,
        departureDate: DateTime(2026, 12, 3),
        travelerCount: 2,
      );

      final row = trip.toMap();
      expect(row, {
        'id': 'trip-1',
        'name': 'Summer in Santorini',
        'type': 'beach',
        'duration_days': 5,
        'departure_date': '2026-12-03T00:00:00.000',
        'traveler_count': 2,
        'reminder_enabled': 0,
        'reminder_time': null,
      });

      final restored = Trip.fromMap(row);
      expect(restored.id, trip.id);
      expect(restored.name, trip.name);
      expect(restored.type, trip.type);
      expect(restored.durationDays, trip.durationDays);
      expect(restored.departureDate, trip.departureDate);
      expect(restored.travelerCount, trip.travelerCount);
      expect(restored.reminderEnabled, isFalse);
      expect(restored.reminderTime, isNull);
    });

    test('unknown stored types fall back to other', () {
      final trip = Trip.fromMap({
        'id': 'x',
        'name': 'Mystery',
        'type': 'spaceflight',
        'duration_days': 1,
        'departure_date': '2026-12-03T00:00:00.000',
        'traveler_count': 1,
        'reminder_enabled': 0,
        'reminder_time': null,
      });
      expect(trip.type, TripType.other);
    });
  });

  group('TripProvider', () {
    late InMemoryTripRepository repository;
    late TripProvider provider;

    setUp(() {
      repository = InMemoryTripRepository();
      provider = TripProvider(repository: repository);
    });

    test('createTrip saves the trip and exposes it', () async {
      final trip = await provider.createTrip(
        name: '  Summer in Santorini  ',
        type: TripType.beach,
        durationDays: 5,
        departureDate: DateTime(2026, 12, 3, 15, 30),
        travelerCount: 2,
      );

      expect(trip.name, 'Summer in Santorini');
      expect(trip.departureDate, DateTime(2026, 12, 3));
      expect(trip.id, isNotEmpty);
      expect(repository.rows, hasLength(1));
      expect(provider.trips.single.id, trip.id);
      expect(provider.tripById(trip.id), same(trip));
      expect(provider.errorMessage, isNull);
    });

    test('saved trips can be retrieved by a fresh provider', () async {
      final created = await provider.createTrip(
        name: 'Banff Lakes',
        type: TripType.camping,
        durationDays: 3,
        departureDate: DateTime(2026, 12, 12),
        travelerCount: 4,
      );

      final reloaded = TripProvider(repository: repository);
      await reloaded.loadTrips();

      final trip = reloaded.tripById(created.id)!;
      expect(trip.name, 'Banff Lakes');
      expect(trip.type, TripType.camping);
      expect(trip.durationDays, 3);
      expect(trip.travelerCount, 4);
      expect(await repository.getTrip(created.id), isNotNull);
    });

    test('each trip gets a unique id', () async {
      final ids = <String>{};
      for (var i = 0; i < 20; i++) {
        final trip = await provider.createTrip(
          name: 'Trip $i',
          type: TripType.city,
          durationDays: 1,
          departureDate: DateTime(2026, 12, 1),
          travelerCount: 1,
        );
        ids.add(trip.id);
      }
      expect(ids, hasLength(20));
    });

    test('rejects invalid input without saving', () async {
      Future<Trip> create({
        String name = 'Trip',
        int days = 1,
        int travelers = 1,
      }) => provider.createTrip(
        name: name,
        type: TripType.other,
        durationDays: days,
        departureDate: DateTime(2026, 12, 1),
        travelerCount: travelers,
      );

      await expectLater(create(name: '   '), throwsArgumentError);
      await expectLater(create(days: 0), throwsRangeError);
      await expectLater(create(travelers: 0), throwsRangeError);
      expect(repository.rows, isEmpty);
      expect(provider.trips, isEmpty);
    });

    test('database failures surface an error and keep state clean', () async {
      repository.failWith = Exception('disk full');

      await expectLater(
        provider.createTrip(
          name: 'Trip',
          type: TripType.family,
          durationDays: 2,
          departureDate: DateTime(2026, 12, 1),
          travelerCount: 3,
        ),
        throwsException,
      );
      expect(provider.trips, isEmpty);
      expect(provider.errorMessage, 'Could not save your trip.');

      await provider.loadTrips();
      expect(provider.errorMessage, 'Could not load your trips.');
      expect(provider.isLoading, isFalse);
    });
  });
}
