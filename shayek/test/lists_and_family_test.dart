import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shayek/models/packing_item.dart';
import 'package:shayek/models/packing_template.dart';
import 'package:shayek/models/trip.dart';
import 'package:shayek/providers/checklist_provider.dart';
import 'package:shayek/providers/template_provider.dart';
import 'package:shayek/providers/trip_provider.dart';
import 'package:shayek/screens/templates_screen.dart';

import 'fakes/in_memory_packing_item_repository.dart';
import 'fakes/in_memory_template_repository.dart';
import 'fakes/in_memory_trip_repository.dart';

/// Template store whose visibility updates always fail.
class _FailingVisibilityRepository extends InMemoryTemplateRepository {
  @override
  Future<void> updateTemplateVisibility(
    String id,
    ListVisibility visibility,
  ) async => throw StateError('db down');
}

void main() {
  testWidgets('a failed public/private change tells the user', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FailingVisibilityRepository();
    await repository.insertTemplate(
      const PackingTemplate(id: 'own-1', name: 'Desert night out'),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TemplateProvider(repository: repository),
          ),
          ChangeNotifierProvider(
            create: (_) => TripProvider(repository: InMemoryTripRepository()),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TemplatesScreen())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('List actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Make public'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not make "Desert night out" public. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('sample public lists are offered next to saved lists', (
    tester,
  ) async {
    final repository = InMemoryTemplateRepository();
    await repository.insertTemplate(
      const PackingTemplate(id: 'own-1', name: 'Desert night out'),
    );
    final provider = TemplateProvider(repository: repository);

    await provider.loadTemplates();

    expect(
      provider.publicLists.map((list) => list.name),
      containsAll(['Weekend Hiking', 'Beach Holiday']),
    );
  });

  test('removing a family member clears their item assignments', () {
    final checklist = ChecklistProvider(
      repository: InMemoryPackingItemRepository(),
    );
    final trip = Trip(
      id: 't1',
      name: 'Amalfi',
      type: TripType.family,
      durationDays: 3,
      departureDate: DateTime(2030, 1, 1),
      travelerCount: 2,
    );
    checklist.generateChecklist(trip);
    checklist.addItem(name: 'Teddy bear', category: 'Other', travelerId: 'kid');
    expect(checklist.assignedCountFor('t1', 'kid'), 1);

    checklist.unassignTraveler('kid');

    expect(checklist.assignedCountFor('t1', 'kid'), 0);
    final PackingItem teddy = checklist.items.firstWhere(
      (item) => item.name == 'Teddy bear',
    );
    expect(teddy.travelerId, isNull);
  });
}
