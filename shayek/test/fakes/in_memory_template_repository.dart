import 'package:shayek/database/template_repository.dart';
import 'package:shayek/models/packing_template.dart';

class InMemoryTemplateRepository implements TemplateRepository {
  final List<PackingTemplate> _templates = [];

  @override
  Future<List<PackingTemplate>> getTemplates() async =>
      List.unmodifiable(_templates);

  @override
  Future<void> insertTemplate(PackingTemplate template) async {
    _templates.add(template);
  }

  @override
  Future<void> updateTemplateName(String id, String name) async {
    final index = _templates.indexWhere((template) => template.id == id);
    if (index < 0) return;
    final template = _templates[index];
    _templates[index] = PackingTemplate(
      id: template.id,
      name: name,
      type: template.type,
      visibility: template.visibility,
      isDiscoverable: template.isDiscoverable,
      items: template.items,
    );
  }

  @override
  Future<void> updateTemplateVisibility(
    String id,
    ListVisibility visibility,
  ) async {
    final index = _templates.indexWhere((template) => template.id == id);
    if (index < 0) return;
    final template = _templates[index];
    _templates[index] = PackingTemplate(
      id: template.id,
      name: template.name,
      type: template.type,
      visibility: visibility,
      isDiscoverable: visibility == ListVisibility.public,
      items: template.items,
    );
  }

  @override
  Future<void> deleteTemplate(String id) async {
    _templates.removeWhere((template) => template.id == id);
  }
}
