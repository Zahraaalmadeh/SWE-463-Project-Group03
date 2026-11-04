// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shayek/app_routes.dart';
import 'package:shayek/main.dart';
import 'package:shayek/screens/navigation_shell.dart';

void main() {
  testWidgets('Shayek app loads smoke test', (tester) async {
    await tester.pumpWidget(const ShayekApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Create trip'), findsOneWidget);
  });

  testWidgets('named routes and main tabs are reachable', (tester) async {
    await tester.pumpWidget(const ShayekApp());

    await tester.tap(find.text('Templates'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Templates'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

    final context = tester.element(find.byType(NavigationShell));
    final navigator = Navigator.of(context);

    navigator.pushNamed(AppRoutes.createTrip);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Create Trip'), findsOneWidget);

    navigator.pushNamed(AppRoutes.checklist);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Packing Checklist'), findsOneWidget);

    await tester.tap(find.text('Family members'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Family Members'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Return checklist'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Return Checklist'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save as template'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Templates'), findsOneWidget);
  });
}
