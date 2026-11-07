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
}
