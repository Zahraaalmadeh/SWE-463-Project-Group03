import 'template_item.dart';
import 'trip.dart';

enum ListVisibility { private, public }

class PackingTemplate {
  const PackingTemplate({
    required this.id,
    required this.name,
    this.type = TripType.other,
    this.visibility = ListVisibility.private,
    this.isDiscoverable = false,
    this.items = const [],
  });

  final String id;
  final String name;
  final TripType type;
  final ListVisibility visibility;
  final bool isDiscoverable;
  final List<TemplateItem> items;
}
