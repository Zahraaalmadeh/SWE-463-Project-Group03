import '../models/packing_template.dart';
import '../models/template_item.dart';
import '../models/trip.dart';
import 'database_service.dart';

abstract interface class TemplateRepository {
  Future<List<PackingTemplate>> getTemplates();
  Future<void> insertTemplate(PackingTemplate template);
  Future<void> updateTemplateName(String id, String name);
  Future<void> updateTemplateVisibility(String id, ListVisibility visibility);
  Future<void> deleteTemplate(String id);
}

class SqfliteTemplateRepository implements TemplateRepository {
  SqfliteTemplateRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  @override
  Future<List<PackingTemplate>> getTemplates() async {
    final database = await _databaseService.database;
    final templates = await database.query('templates', orderBy: 'name ASC');
    final result = <PackingTemplate>[];
    for (final row in templates) {
      final itemRows = await database.query(
        'template_items',
        where: 'template_id = ?',
        whereArgs: [row['id']],
        orderBy: 'name ASC',
      );
      result.add(
        PackingTemplate(
          id: row['id']! as String,
          name: row['name']! as String,
          type: TripType.values.firstWhere(
            (type) => type.name == row['type'],
            orElse: () => TripType.other,
          ),
          visibility: ListVisibility.values.firstWhere(
            (visibility) => visibility.name == row['visibility'],
            orElse: () => ListVisibility.private,
          ),
          isDiscoverable: row['visibility'] == ListVisibility.public.name,
          items: itemRows.map(_itemFromRow).toList(),
        ),
      );
    }
    return result;
  }

  @override
  Future<void> insertTemplate(PackingTemplate template) async {
    final database = await _databaseService.database;
    await database.transaction((transaction) async {
      await transaction.insert('templates', {
        'id': template.id,
        'name': template.name,
        'type': template.type.name,
        'visibility': template.visibility.name,
      });
      for (final item in template.items) {
        await transaction.insert('template_items', _itemToRow(item));
      }
    });
  }

  @override
  Future<void> updateTemplateName(String id, String name) async {
    final database = await _databaseService.database;
    await database.update(
      'templates',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> updateTemplateVisibility(
    String id,
    ListVisibility visibility,
  ) async {
    final database = await _databaseService.database;
    await database.update(
      'templates',
      {'visibility': visibility.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final database = await _databaseService.database;
    await database.delete('templates', where: 'id = ?', whereArgs: [id]);
  }

  TemplateItem _itemFromRow(Map<String, Object?> row) => TemplateItem(
    id: row['id']! as String,
    templateId: row['template_id']! as String,
    name: row['name']! as String,
    category: row['category']! as String,
    quantity: row['quantity']! as int,
  );

  Map<String, Object?> _itemToRow(TemplateItem item) => {
    'id': item.id,
    'template_id': item.templateId,
    'name': item.name,
    'category': item.category,
    'quantity': item.quantity,
  };
}
