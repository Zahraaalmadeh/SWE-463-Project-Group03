import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shayek/app_routes.dart';
import 'package:shayek/models/trip.dart';
import 'package:shayek/providers/checklist_provider.dart';
import 'package:shayek/providers/template_provider.dart';
import 'package:shayek/providers/trip_provider.dart';

import 'fakes/in_memory_trip_repository.dart';

/// Mirrors ShayekApp's providers and routes, but with an in-memory trips
/// table so the real Home and Create Trip screens share one data source.
Future<void> _pumpApp(WidgetTester tester, InMemoryTripRepository repo) async {
  await tester.binding.setSurfaceSize(const Size(900, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider(repository: repo)),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => TemplateProvider()),
      ],
      child: const MaterialApp(
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    ),
  );
  // Home loads trips after its first frame.
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home lists trips already saved in the database', (tester) async {
    final repo = InMemoryTripRepository();
    await repo.insertTrip(
      Trip(
        id: 'seed-1',
        name: 'Amalfi Coast',
        type: TripType.beach,
        durationDays: 7,
        departureDate: DateTime(2027, 6, 1),
        travelerCount: 2,
      ),
    );

    await _pumpApp(tester, repo);

    expect(find.text('Upcoming Trips'), findsOneWidget);
    expect(find.text('1 trip'), findsOneWidget);
    expect(find.text('Amalfi Coast'), findsOneWidget);
  });

  testWidgets('a trip created from Home appears on Home afterwards', (
    tester,
  ) async {
    final repo = InMemoryTripRepository();
    await _pumpApp(tester, repo);

    // Empty database: Home shows its empty state.
    expect(find.text('Your next adventure starts here'), findsOneWidget);

    await tester.tap(find.text('New Trip'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you headed?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Banff Lakes');
    await tester.tap(find.text('Camping'));
    await tester.tap(find.byTooltip('Increase Travelers'));
    await tester.pump();
    await tester.ensureVisible(find.text('mm/dd/yyyy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('mm/dd/yyyy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate Packing List'));
    await tester.pumpAndSettle();

    // Saved to the trips table and handed to the checklist.
    expect(repo.rows, hasLength(1));
    expect(repo.rows.single['name'], 'Banff Lakes');
    expect(find.text('Where are you headed?'), findsNothing);

    // Back from the checklist lands on Home, which now lists the trip.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.text('Upcoming Trips'), findsOneWidget);
    expect(find.text('1 trip'), findsOneWidget);
    expect(find.text('Banff Lakes'), findsOneWidget);
    expect(find.text('Camping'), findsWidgets);

    // A fresh load from the database (e.g. next app start) still has it.
    await tester
        .element(find.text('Banff Lakes'))
        .read<TripProvider>()
        .loadTrips();
    await tester.pumpAndSettle();
    expect(find.text('Banff Lakes'), findsOneWidget);
  });
}
