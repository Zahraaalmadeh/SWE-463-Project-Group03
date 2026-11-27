import 'package:flutter/foundation.dart';

import '../database/template_repository.dart';
import '../models/packing_template.dart';
import '../models/packing_item.dart';
import '../models/template_item.dart';
import '../models/trip.dart';

/// Owns reusable templates and will coordinate template CRUD with persistence.
class TemplateProvider extends ChangeNotifier {
  TemplateProvider({TemplateRepository? repository})
    : _repository = repository ?? SqfliteTemplateRepository();

  final TemplateRepository _repository;
  final List<PackingTemplate> _templates = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  int _idCounter = 0;

  List<PackingTemplate> get templates => List.unmodifiable(_templates);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTemplates() async {
    if (_hasLoaded || _isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _templates
        ..clear()
        ..addAll(await _repository.getTemplates());
      if (_templates.isEmpty) {
        _templates.addAll(_samplePublicLists);
      }
      _hasLoaded = true;
    } catch (error) {
      _errorMessage = 'Could not load templates. Please try again.';
      debugPrint('Failed to load templates: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTemplate({
    required String name,
    required PackingTemplate template,
    required List<PackingItem> items,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Template name cannot be empty.');
    }
    final id = _newId();
    final saved = PackingTemplate(
      id: id,
      name: trimmedName,
      type: template.type,
      visibility: template.visibility,
      isDiscoverable: template.isDiscoverable,
      items: [
        for (final item in items)
          TemplateItem(
            id: '$id-item-${_idCounter++}',
            templateId: id,
            name: item.name,
            category: item.category,
            quantity: item.quantity,
          ),
      ],
    );
    await _repository.insertTemplate(saved);
    _templates
      ..add(saved)
      ..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> renameTemplate(PackingTemplate template, String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Template name cannot be empty.');
    }
    await _repository.updateTemplateName(template.id, trimmedName);
    final index = _templates.indexWhere((item) => item.id == template.id);
    if (index >= 0) {
      _templates[index] = PackingTemplate(
        id: template.id,
        name: trimmedName,
        type: template.type,
        visibility: template.visibility,
        isDiscoverable: template.isDiscoverable,
        items: template.items,
      );
      notifyListeners();
    }
  }

  Future<void> deleteTemplate(PackingTemplate template) async {
    await _repository.deleteTemplate(template.id);
    _templates.removeWhere((item) => item.id == template.id);
    notifyListeners();
  }

  Future<void> updateVisibility(
    PackingTemplate template,
    ListVisibility visibility,
  ) async {
    final updated = PackingTemplate(
      id: template.id,
      name: template.name,
      type: template.type,
      visibility: visibility,
      isDiscoverable: visibility == ListVisibility.public,
      items: template.items,
    );
    await _repository.updateTemplateVisibility(template.id, visibility);
    final index = _templates.indexWhere((item) => item.id == template.id);
    if (index >= 0) {
      _templates[index] = updated;
      notifyListeners();
    }
  }

  List<PackingTemplate> get publicLists => _templates
      .where((template) => template.visibility == ListVisibility.public)
      .toList(growable: false);

  static final _samplePublicLists = [
    PackingTemplate(
      id: 'sample-hiking-list',
      name: 'Weekend Hiking',
      type: TripType.camping,
      visibility: ListVisibility.public,
      isDiscoverable: true,
      items: [
        TemplateItem(
          id: 'sample-hiking-shoes',
          templateId: 'sample-hiking-list',
          name: 'Hiking shoes',
          category: 'Clothing',
        ),
        TemplateItem(
          id: 'sample-hiking-water',
          templateId: 'sample-hiking-list',
          name: 'Water bottle',
          category: 'Essentials',
        ),
      ],
    ),
    PackingTemplate(
      id: 'sample-beach-list',
      name: 'Beach Holiday',
      type: TripType.beach,
      visibility: ListVisibility.public,
      isDiscoverable: true,
      items: [
        TemplateItem(
          id: 'sample-beach-swimsuit',
          templateId: 'sample-beach-list',
          name: 'Swimsuit',
          category: 'Clothing',
        ),
        TemplateItem(
          id: 'sample-beach-sunscreen',
          templateId: 'sample-beach-list',
          name: 'Sunscreen',
          category: 'Toiletries',
        ),
      ],
    ),
  ];

  String _newId() =>
      'template-${DateTime.now().microsecondsSinceEpoch}-${_idCounter++}';
}
