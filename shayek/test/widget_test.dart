// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:shayek/main.dart';

void main() {
  testWidgets('Shayek app loads smoke test', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Shayek'), findsOneWidget);
    expect(find.text('Ready for your next adventure?'), findsOneWidget);
    expect(find.text('New Trip'), findsOneWidget);
    expect(find.text('Upcoming Trips'), findsOneWidget);
  });
}
