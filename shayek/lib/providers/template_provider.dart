import 'package:flutter/foundation.dart';

import '../models/packing_template.dart';

/// Owns reusable templates and will coordinate template CRUD with persistence.
class TemplateProvider extends ChangeNotifier {
  final List<PackingTemplate> _templates = [];
  final bool _isLoading = false;
  String? _errorMessage;

  List<PackingTemplate> get templates => List.unmodifiable(_templates);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
}
