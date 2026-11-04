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
    await tester.pumpWidget(const ShayekApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Create Trip'), findsOneWidget);
  });

  testWidgets('Home, Create Trip, and Templates are reachable', (tester) async {
    await tester.pumpWidget(const ShayekApp());

    await tester.tap(find.text('Templates'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Templates'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

    await tester.tap(find.text('Create Trip'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Create Trip'), findsOneWidget);
  });
}
