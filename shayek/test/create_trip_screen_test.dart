import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shayek/screens/create_trip_screen.dart';

/// Typical phone viewport so layout issues surface at mobile sizes.
const _phoneSize = Size(390, 844);

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(_phoneSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const MaterialApp(home: CreateTripScreen()));
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
      containsSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Camping')),
      containsSemantics(isSelected: false),
    );

    await tester.tap(find.text('Camping'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('Camping')),
      containsSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Beach')),
      containsSemantics(isSelected: false),
    );
    semantics.dispose();
  });
}
