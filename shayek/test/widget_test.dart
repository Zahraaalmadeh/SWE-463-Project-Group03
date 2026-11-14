// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shayek/app_routes.dart';
import 'package:shayek/providers/checklist_provider.dart';
import 'package:shayek/providers/template_provider.dart';
import 'package:shayek/providers/trip_provider.dart';

import 'fakes/in_memory_template_repository.dart';
import 'fakes/in_memory_trip_repository.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(900, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TripProvider(repository: InMemoryTripRepository()),
        ),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(
          create: (_) => TemplateProvider(
            repository: InMemoryTemplateRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Shayek app loads smoke test', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Shayek'), findsWidgets);
    expect(find.text('New Trip'), findsOneWidget);
  });

  testWidgets('Home, Create Trip, and Templates are reachable', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Lists').first);
    await tester.pumpAndSettle();
    expect(find.text('Your Lists'), findsOneWidget);

    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
    expect(find.text('Shayek'), findsWidgets);

    await tester.tap(find.text('New Trip'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you headed?'), findsOneWidget);
  });

  testWidgets('Create Trip back button returns to Home', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('New Trip'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you headed?'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you headed?'), findsNothing);
    expect(find.text('Ready for your next adventure?'), findsOneWidget);
  });
}
