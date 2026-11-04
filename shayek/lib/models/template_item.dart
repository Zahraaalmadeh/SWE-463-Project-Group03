class TemplateItem {
  const TemplateItem({
    required this.id,
    required this.templateId,
    required this.name,
    required this.category,
    this.quantity = 1,
  });

  final String id;
  final String templateId;
  final String name;
  final String category;
  final int quantity;
}
