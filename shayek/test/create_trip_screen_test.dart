import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shayek/app_routes.dart';
import 'package:shayek/models/trip.dart';
import 'package:shayek/providers/checklist_provider.dart';
import 'package:shayek/providers/trip_provider.dart';
import 'package:shayek/screens/checklist_screen.dart';
import 'package:shayek/screens/create_trip_screen.dart';

import 'fakes/in_memory_trip_repository.dart';

/// Typical phone viewport so layout issues surface at mobile sizes.
const _phoneSize = Size(390, 844);

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(_phoneSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const MaterialApp(home: CreateTripScreen()));
}

/// Opens the screen from a launcher route, as Home does, so that leaving the
/// screen can be observed.
Future<TripProvider> _pumpFromLauncher(
  WidgetTester tester,
  InMemoryTripRepository repository,
) async {
  await tester.binding.setSurfaceSize(_phoneSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final provider = TripProvider(repository: repository);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: provider),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRoutes.generateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const CreateTripScreen()),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return provider;
}

Future<void> _fillValidTrip(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'Summer in Santorini');
  await tester.tap(find.text('Family'));
  await tester.tap(find.byTooltip('Increase Travelers'));
  await tester.pump();
  await tester.ensureVisible(find.text('mm/dd/yyyy'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('mm/dd/yyyy'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders every field from the design', (tester) async {
    await _pumpScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('New Trip'), findsOneWidget);
    expect(find.text('Where are you headed?'), findsOneWidget);
    expect(find.text('Trip name'), findsOneWidget);
    for (final label in [
      'Beach',
      'Business',
      'Family',
      'Camping',
      'City',
      'Other',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Duration (days)'), findsOneWidget);
    expect(find.text('Travelers'), findsOneWidget);
    expect(find.text('Departure date'), findsOneWidget);
    expect(find.text('Generate Packing List'), findsOneWidget);
  });

  testWidgets('only one trip type is selected at a time', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpScreen(tester);

    expect(
      tester.getSemantics(find.text('Beach')),
      isSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Camping')),
      isSemantics(isSelected: false),
    );

    await tester.tap(find.text('Camping'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('Camping')),
      isSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Beach')),
      isSemantics(isSelected: false),
    );
    semantics.dispose();
  });

  testWidgets('duration and travelers counters stay within limits', (
    tester,
  ) async {
    await _pumpScreen(tester);
    final increaseDays = find.byTooltip('Increase Duration (days)');
    final decreaseDays = find.byTooltip('Decrease Duration (days)');
    final increaseTravelers = find.byTooltip('Increase Travelers');
    final decreaseTravelers = find.byTooltip('Decrease Travelers');

    expect(find.text('5'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(increaseDays);
    await tester.pump();
    expect(find.text('6'), findsOneWidget);

    for (var i = 0; i < 10; i++) {
      await tester.tap(decreaseDays);
      await tester.pump();
    }
    expect(find.text('${CreateTripScreen.minDurationDays}'), findsOneWidget);

    await tester.tap(increaseTravelers);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    for (var i = 0; i < 10; i++) {
      await tester.tap(decreaseTravelers);
      await tester.pump();
    }
    // Both counters are now at their minimum of 1 and cannot go lower.
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('0'), findsNothing);

    for (var i = 0; i < CreateTripScreen.maxTravelers + 5; i++) {
      await tester.tap(increaseTravelers);
      await tester.pump();
    }
    expect(find.text('${CreateTripScreen.maxTravelers}'), findsOneWidget);
    expect(find.text('${CreateTripScreen.maxTravelers + 1}'), findsNothing);
  });

  testWidgets('departure date can be picked', (tester) async {
    await _pumpScreen(tester);
    expect(find.text('mm/dd/yyyy'), findsOneWidget);

    await tester.ensureVisible(find.text('mm/dd/yyyy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('mm/dd/yyyy'));
    await tester.pumpAndSettle();
    expect(find.text('Select departure date'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    expect(find.text('mm/dd/yyyy'), findsNothing);
    expect(
      find.text('${two(now.month)}/${two(now.day)}/${now.year}'),
      findsOneWidget,
    );
  });

  testWidgets('cancelling the date picker keeps the field empty', (
    tester,
  ) async {
    await _pumpScreen(tester);

    await tester.ensureVisible(find.text('mm/dd/yyyy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('mm/dd/yyyy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('mm/dd/yyyy'), findsOneWidget);
  });

  testWidgets('submitting empty form shows required-field errors', (
    tester,
  ) async {
    await _pumpScreen(tester);

    await tester.tap(find.text('Generate Packing List'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a trip name.'), findsOneWidget);

    // Once the name is valid, the date error is scrolled into view.
    await tester.enterText(find.byType(TextField), 'Weekend away');
    await tester.tap(find.text('Generate Packing List'));
    await tester.pumpAndSettle();
    expect(find.text('Please choose a departure date.'), findsOneWidget);
  });

  testWidgets('whitespace-only names are rejected', (tester) async {
    await _pumpScreen(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Generate Packing List'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a trip name.'), findsOneWidget);
  });

  testWidgets('errors clear once the fields are fixed', (tester) async {
    await _pumpScreen(tester);

    await tester.tap(find.text('Generate Packing List'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Summer in Santorini');
    await tester.pump();
    expect(find.text('Please enter a trip name.'), findsNothing);

    await tester.ensureVisible(find.text('mm/dd/yyyy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('mm/dd/yyyy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Please choose a departure date.'), findsNothing);
  });

  testWidgets('trip name is capped at the maximum length', (tester) async {
    await _pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'a' * 80);
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text.length, CreateTripScreen.maxNameLength);
  });

  testWidgets('a valid trip is saved with the entered details', (tester) async {
    final repository = InMemoryTripRepository();
    final provider = await _pumpFromLauncher(tester, repository);

    await _fillValidTrip(tester);
    await tester.tap(find.text('Generate Packing List'));
    await tester.pumpAndSettle();

    expect(repository.rows, hasLength(1));
    final saved = provider.trips.single;
    expect(saved.name, 'Summer in Santorini');
    expect(saved.type, TripType.family);
    expect(saved.durationDays, 5);
    expect(saved.travelerCount, 3);
    final now = DateTime.now();
    expect(saved.departureDate, DateTime(now.year, now.month, now.day));

    expect(find.text('Where are you headed?'), findsNothing);
    expect(find.text('"Summer in Santorini" was saved.'), findsOneWidget);
  });

  testWidgets('Generate Packing List opens the checklist for the new trip', (
    tester,
  ) async {
    final repository = InMemoryTripRepository();
    final provider = await _pumpFromLauncher(tester, repository);

    await _fillValidTrip(tester);
    await tester.tap(find.text('Generate Packing List'));
    await tester.pumpAndSettle();

    final checklist = tester.widget<ChecklistScreen>(
      find.byType(ChecklistScreen),
    );
    expect(checklist.trip!.id, provider.trips.single.id);
    expect(find.text('Summer in Santorini'), findsOneWidget);

    final element = tester.element(find.byType(ChecklistScreen));
    final checklistProvider = Provider.of<ChecklistProvider>(
      element,
      listen: false,
    );
    expect(checklistProvider.selectedTripId, provider.trips.single.id);
    expect(checklistProvider.items, isNotEmpty);

    // The form was replaced, so going back returns to the launching screen.
    Navigator.of(element).pop();
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Where are you headed?'), findsNothing);
  });

  testWidgets('invalid input never reaches the database', (tester) async {
    final repository = InMemoryTripRepository();
    await _pumpFromLauncher(tester, repository);

    await tester.tap(find.text('Generate Packing List'));
    await tester.pumpAndSettle();

    expect(repository.rows, isEmpty);
    expect(find.text('Where are you headed?'), findsOneWidget);
  });

  testWidgets('a save failure keeps the user on the form', (tester) async {
    final repository = InMemoryTripRepository()
      ..failWith = Exception('database unavailable');
    await _pumpFromLauncher(tester, repository);

    await _fillValidTrip(tester);
    await tester.tap(find.text('Generate Packing List'));
    await tester.pumpAndSettle();

    expect(find.text('Where are you headed?'), findsOneWidget);
    expect(
      find.text('Could not save your trip. Please try again.'),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });
}
