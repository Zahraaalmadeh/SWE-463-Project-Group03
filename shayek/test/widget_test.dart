// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shayek/main.dart';

void main() {
  testWidgets('Shayek app loads smoke test', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ShayekApp());

    expect(find.text('Shayek'), findsOneWidget);
    expect(find.text('New Trip'), findsOneWidget);
  });

  testWidgets('Home, Create Trip, and Templates are reachable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ShayekApp());

    await tester.tap(find.text('Templates'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Templates'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Shayek'), findsOneWidget);

    await tester.tap(find.text('New Trip'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you headed?'), findsOneWidget);
  });

  testWidgets('Create Trip back button returns to Home', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ShayekApp());

    await tester.tap(find.text('New Trip'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you headed?'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you headed?'), findsNothing);
    expect(find.text('Upcoming Trips'), findsOneWidget);
  });
}
