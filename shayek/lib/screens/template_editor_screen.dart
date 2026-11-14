import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/packing_item.dart';
import '../models/packing_template.dart';
import '../models/trip.dart';
import '../providers/checklist_provider.dart';
import '../providers/template_provider.dart';
import '../theme/app_theme.dart';

class TemplateEditorScreen extends StatefulWidget {
  const TemplateEditorScreen({super.key, this.isModal = false});

  final bool isModal;

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _nameController = TextEditingController();
  final _items = <PackingItem>[];
  TripType _type = TripType.other;
  ListVisibility _visibility = ListVisibility.private;
  bool _isSaving = false;
  String? _validationMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isModal
          ? null
          : AppBar(
              backgroundColor: AppColors.background,
              title: const Text('New List'),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
            children: [
              if (_validationMessage != null) ...[
                _ValidationBanner(message: _validationMessage!),
                const SizedBox(height: 16),
              ],
              const Text('Create a packing list', style: AppText.display),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_validationMessage != null) {
                    setState(() => _validationMessage = null);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Template name',
                  hintText: 'e.g. Ski Weekend',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<TripType>(
                initialValue: _type,
                borderRadius: BorderRadius.circular(20),
                decoration: const InputDecoration(labelText: 'Trip type'),
                items: TripType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_typeLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (type) {
                  if (type != null) setState(() => _type = type);
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<ListVisibility>(
                initialValue: _visibility,
                borderRadius: BorderRadius.circular(20),
                decoration: const InputDecoration(labelText: 'Visibility'),
                items: const [
                  DropdownMenuItem(
                    value: ListVisibility.private,
                    child: Text('Private - only me'),
                  ),
                  DropdownMenuItem(
                    value: ListVisibility.public,
                    child: Text('Public - discoverable by others'),
                  ),
                ],
                onChanged: (visibility) {
                  if (visibility != null) {
                    setState(() => _visibility = visibility);
                  }
                },
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: Text('Packing items', style: AppText.title),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showItemEditor,
                    icon: const Icon(Icons.add),
                    label: const Text('Add item'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'Add at least one item to save this template.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                )
              else
                ..._items.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.category} · Quantity ${item.quantity}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Delete item',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _items.remove(item)),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Template'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showItemEditor() async {
    final result = await showDialog<PackingItem>(
      context: context,
      builder: (_) => const _AddTemplateItemDialog(),
    );
    if (result != null && mounted) setState(() => _items.add(result));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _validationMessage = 'Enter a list name.');
      return;
    }
    if (_items.isEmpty) {
      setState(
        () => _validationMessage = 'Add at least one item before saving.',
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await context.read<TemplateProvider>().createTemplate(
        name: name,
        template: PackingTemplate(
          id: 'template-editor',
          name: name,
          type: _type,
          visibility: _visibility,
          isDiscoverable: _visibility == ListVisibility.public,
        ),
        items: _items,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      debugPrint('Failed to create template: $error');
      if (!mounted) return;
      setState(() => _isSaving = false);
      setState(
        () => _validationMessage = 'Could not save the list. Please try again.',
      );
    }
  }

  static String _typeLabel(TripType type) =>
      type.name[0].toUpperCase() + type.name.substring(1);
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1B8B1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTemplateItemDialog extends StatefulWidget {
  const _AddTemplateItemDialog();

  @override
  State<_AddTemplateItemDialog> createState() => _AddTemplateItemDialogState();
}

class _AddTemplateItemDialogState extends State<_AddTemplateItemDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _otherCategoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _category = ChecklistProvider.categories.first;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      title: const Text('Add packing item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an item name'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                borderRadius: BorderRadius.circular(20),
                decoration: const InputDecoration(labelText: 'Category'),
                items: ChecklistProvider.categories
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              if (_category == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otherCategoryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Custom category (optional)',
                    hintText: 'e.g. Hiking gear',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) =>
                    int.tryParse(value ?? '') == null || int.parse(value!) < 1
                    ? 'Enter a quantity of at least 1'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _addItem, child: const Text('Add')),
      ],
    );
  }

  void _addItem() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      PackingItem(
        id: 'editor-${DateTime.now().microsecondsSinceEpoch}',
        tripId: 'template-editor',
        name: _nameController.text.trim(),
        category:
            _category == 'Other' &&
                _otherCategoryController.text.trim().isNotEmpty
            ? _otherCategoryController.text.trim()
            : _category,
        quantity: int.parse(_quantityController.text),
      ),
    );
  }
}
