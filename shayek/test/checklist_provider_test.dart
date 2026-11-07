import 'package:flutter_test/flutter_test.dart';
import 'package:shayek/models/packing_item.dart';
import 'package:shayek/models/trip.dart';
import 'package:shayek/providers/checklist_provider.dart';

void main() {
  group('ChecklistProvider', () {
    late ChecklistProvider provider;

    setUp(() => provider = ChecklistProvider());
    tearDown(() => provider.dispose());

    test('generates trip-specific items and derives packing progress', () {
      final trip = Trip(
        id: 'trip-1',
        name: 'Beach break',
        type: TripType.beach,
        durationDays: 4,
        departureDate: DateTime(2026, 8, 1),
        travelerCount: 2,
      );

      provider.generateChecklist(trip);

      expect(provider.selectedTripId, 'trip-1');
      expect(provider.items.any((item) => item.name == 'Swimsuit'), isTrue);
      expect(provider.items.firstWhere((item) => item.name == 'Tops').quantity, 8);
      expect(provider.progress, 0);
      final item = provider.items.first;
      provider.togglePacked(item.id);
      expect(provider.packedCount, 1);
      expect(provider.progress, closeTo(1 / provider.totalCount, 0.0001));
    });

    test('supports adding, editing, removing, and isolating trip items', () {
      provider.selectTrip('first');
      final item = provider.addItem(name: '  Book  ', category: 'Other');
      expect(provider.items.single.name, 'Book');

      provider.updateItem(_copyItem(item, name: 'Guidebook'));
      expect(provider.items.single.name, 'Guidebook');

      provider.selectTrip('second');
      expect(provider.items, isEmpty);
      provider.selectTrip('first');
      provider.removeItem(item.id);
      expect(provider.items, isEmpty);
    });

    test('regenerating one trip leaves other trips untouched', () {
      final beachTrip = Trip(
        id: 'beach',
        name: 'Beach',
        type: TripType.beach,
        durationDays: 2,
        departureDate: DateTime(2026, 8, 1),
        travelerCount: 1,
      );
      provider.generateChecklist(beachTrip);
      final beachItemsBefore = provider.items;

      final campingTrip = Trip(
        id: 'camping',
        name: 'Camping',
        type: TripType.camping,
        durationDays: 2,
        departureDate: DateTime(2026, 8, 1),
        travelerCount: 1,
      );
      provider.generateChecklist(campingTrip);
      final campingCount = provider.items.length;

      provider.generateChecklist(beachTrip);
      expect(provider.items.any((item) => item.name == 'Swimsuit'), isTrue);
      expect(provider.items.length, beachItemsBefore.length);

      provider.selectTrip('camping');
      expect(provider.items.length, campingCount);
      expect(provider.items.any((item) => item.name == 'Camping tent'), isTrue);
    });
  });
}

PackingItem _copyItem(PackingItem item, {required String name}) => PackingItem(
      id: item.id,
      tripId: item.tripId,
      travelerId: item.travelerId,
      name: name,
      category: item.category,
      quantity: item.quantity,
      isPacked: item.isPacked,
      isShared: item.isShared,
      isReturnItem: item.isReturnItem,
    );
