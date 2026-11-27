import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shayek/app_routes.dart';
import 'package:shayek/models/packing_item.dart';
import 'package:shayek/models/trip.dart';
import 'package:shayek/providers/checklist_provider.dart';
import 'package:shayek/providers/template_provider.dart';
import 'package:shayek/providers/traveler_provider.dart';
import 'package:shayek/providers/trip_provider.dart';
import 'package:shayek/screens/family_members_screen.dart';
import 'package:shayek/screens/return_checklist_screen.dart';

import 'fakes/in_memory_packing_item_repository.dart';
import 'fakes/in_memory_template_repository.dart';
import 'fakes/in_memory_traveler_repository.dart';
import 'fakes/in_memory_trip_repository.dart';

Trip _trip(
  String id,
  String name,
  DateTime departure, {
  bool reminder = false,
}) => Trip(
  id: id,
  name: name,
  type: TripType.family,
  durationDays: 5,
  departureDate: departure,
  travelerCount: 4,
  reminderEnabled: reminder,
  reminderTime: reminder ? DateTime(2026, 1, 1, 21) : null,
);

PackingItem _item(String id, String tripId, {bool packed = false}) =>
    PackingItem(
      id: id,
      tripId: tripId,
      name: 'Item $id',
      category: 'Clothing',
      isPacked: packed,
    );

/// The real app routes and providers, backed by in-memory repositories.
Future<ChecklistProvider> _pumpHome(
  WidgetTester tester, {
  required InMemoryTripRepository trips,
  InMemoryPackingItemRepository? items,
}) async {
  await tester.binding.setSurfaceSize(const Size(1280, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final checklist = ChecklistProvider(
    repository: items ?? InMemoryPackingItemRepository(),
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider(repository: trips)),
        ChangeNotifierProvider.value(value: checklist),
        ChangeNotifierProvider(
          create: (_) =>
              TemplateProvider(repository: InMemoryTemplateRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              TravelerProvider(repository: InMemoryTravelerRepository()),
        ),
      ],
      child: const MaterialApp(
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return checklist;
}

void main() {
  final soon = DateTime.now().add(const Duration(days: 30));

  testWidgets('a load failure shows an error and Try again recovers', (
    tester,
  ) async {
    final trips = InMemoryTripRepository()..failWith = StateError('db down');
    trips.rows.add(_trip('t1', 'Amalfi Coast', soon).toMap());

    await _pumpHome(tester, trips: trips);
    expect(find.text('Could not load trips. Please try again.'), findsOne);
    expect(find.text('Amalfi Coast'), findsNothing);

    trips.failWith = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Amalfi Coast'), findsOneWidget);
  });

  testWidgets('cards show packed counts from the saved checklist', (
    tester,
  ) async {
    final trips = InMemoryTripRepository();
    trips.rows.add(_trip('t1', 'Amalfi Coast', soon).toMap());
    final items = InMemoryPackingItemRepository();
    for (final item in [
      _item('a', 't1', packed: true),
      _item('b', 't1'),
      _item('c', 't1'),
      _item('d', 't1', packed: true),
    ]) {
      await items.insertItem(item);
    }

    await _pumpHome(tester, trips: trips, items: items);

    expect(find.text('2 of 4 packed'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('packing an item updates the Home card (shared state)', (
    tester,
  ) async {
    final trips = InMemoryTripRepository();
    trips.rows.add(_trip('t1', 'Amalfi Coast', soon).toMap());
    final items = InMemoryPackingItemRepository();
    await items.insertItem(_item('a', 't1'));
    await items.insertItem(_item('b', 't1'));

    final checklist = await _pumpHome(tester, trips: trips, items: items);
    expect(find.text('0 of 2 packed'), findsOneWidget);

    checklist.selectTrip('t1');
    checklist.togglePacked('a');
    await tester.pumpAndSettle();

    expect(find.text('1 of 2 packed'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('a trip with no items says so instead of 0 of 0', (tester) async {
    final trips = InMemoryTripRepository();
    trips.rows.add(_trip('t1', 'Amalfi Coast', soon).toMap());

    await _pumpHome(tester, trips: trips);

    expect(find.text('No items yet'), findsOneWidget);
  });

  testWidgets('trips are listed soonest departure first after loading', (
    tester,
  ) async {
    final trips = InMemoryTripRepository();
    // Stored out of order, as the database may return them.
    trips.rows.add(
      _trip('late', 'Later trip', soon.add(const Duration(days: 60))).toMap(),
    );
    trips.rows.add(_trip('early', 'Sooner trip', soon).toMap());

    await _pumpHome(tester, trips: trips);

    final sooner = tester.getTopLeft(find.text('Sooner trip'));
    final later = tester.getTopLeft(find.text('Later trip'));
    expect(
      sooner.dy < later.dy || (sooner.dy == later.dy && sooner.dx < later.dx),
      isTrue,
    );
  });

  testWidgets('a reminder banner shows for a trip leaving tomorrow', (
    tester,
  ) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final trips = InMemoryTripRepository();
    trips.rows.add(
      _trip(
        't1',
        'Amalfi Coast',
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        reminder: true,
      ).toMap(),
    );
    trips.rows.add(_trip('t2', 'Far trip', soon, reminder: true).toMap());

    await _pumpHome(tester, trips: trips);

    expect(find.textContaining('Amalfi Coast leaves tomorrow.'), findsOne);
    expect(find.textContaining('Far trip leaves'), findsNothing);
    // Both trips with a reminder show the badge on their card.
    expect(find.text('Reminder 9:00 PM'), findsNWidgets(2));
  });

  testWidgets('card links open Family members and Return checklist', (
    tester,
  ) async {
    final trips = InMemoryTripRepository();
    trips.rows.add(_trip('t1', 'Amalfi Coast', soon).toMap());

    await _pumpHome(tester, trips: trips);

    await tester.tap(find.text('Family members'));
    await tester.pumpAndSettle();
    expect(find.byType(FamilyMembersScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(FamilyMembersScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Return checklist'));
    await tester.pumpAndSettle();
    expect(find.byType(ReturnChecklistScreen), findsOneWidget);
  });
}
