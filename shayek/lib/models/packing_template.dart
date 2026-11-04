import 'template_item.dart';

class PackingTemplate {
  const PackingTemplate({
    required this.id,
    required this.name,
    this.items = const [],
  });

  final String id;
  final String name;
  final List<TemplateItem> items;
}
