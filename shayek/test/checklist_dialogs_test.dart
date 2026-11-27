import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shayek/models/trip.dart';
import 'package:shayek/providers/checklist_provider.dart';
import 'package:shayek/providers/template_provider.dart';
import 'package:shayek/screens/checklist_screen.dart';

import 'fakes/in_memory_template_repository.dart';

/// These dialogs used to dispose their text controllers as soon as the
/// dialog returned, while the field was still on screen for the closing
/// animation, which crashed the app. Each test closes a dialog and lets the
/// animation finish.
Future<(ChecklistProvider, InMemoryTemplateRepository)> _pumpChecklist(
  WidgetTester tester,
) async {
  await tester.binding.setSurfaceSize(const Size(1280, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final checklist = ChecklistProvider();
  final templates = InMemoryTemplateRepository();
  final trip = Trip(
    id: 'trip-1',
    name: 'Beach break',
    type: TripType.beach,
    durationDays: 4,
    departureDate: DateTime(2030, 8, 1),
    travelerCount: 2,
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: checklist),
        ChangeNotifierProvider(
          create: (_) => TemplateProvider(repository: templates),
        ),
      ],
      child: MaterialApp(home: ChecklistScreen(trip: trip)),
    ),
  );
  await tester.pumpAndSettle();
  return (checklist, templates);
}

void main() {
  testWidgets('Save as list closes without crashing and saves the list', (
    tester,
  ) async {
    final (_, templates) = await _pumpChecklist(tester);

    await tester.tap(find.byTooltip('Checklist actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save as list'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Template saved.'), findsOneWidget);
    expect(await templates.getTemplates(), hasLength(1));
  });

  testWidgets('cancelling Save as list closes without crashing', (
    tester,
  ) async {
    final (_, templates) = await _pumpChecklist(tester);

    await tester.tap(find.byTooltip('Checklist actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save as list'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(await templates.getTemplates(), isEmpty);
  });

  testWidgets('Add item dialog adds the item and closes cleanly', (
    tester,
  ) async {
    final (checklist, _) = await _pumpChecklist(tester);
    final before = checklist.totalCount;

    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Item name'),
      'Beach umbrella',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(checklist.totalCount, before + 1);
    expect(find.text('Beach umbrella'), findsOneWidget);
  });

  testWidgets('Regenerate checklist dialog closes cleanly', (tester) async {
    await _pumpChecklist(tester);

    await tester.tap(find.byTooltip('Checklist actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regenerate checklist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Your checklist has been regenerated.'), findsOneWidget);
  });
}
