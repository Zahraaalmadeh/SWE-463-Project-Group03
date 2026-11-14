import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/packing_item.dart';
import '../models/packing_template.dart';
import '../models/trip.dart';
import '../providers/checklist_provider.dart';
import '../providers/template_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_bottom_navigation_bar.dart';
import '../widgets/text_prompt_dialog.dart';

/// Checklist generation and management screen for a trip.
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key, this.trip, this.template});

  final Trip? trip;
  final PackingTemplate? template;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  static const _muted = AppColors.muted;

  late Trip _trip;
  String _query = '';
  String _categoryFilter = 'All';
  _ChecklistFilter _statusFilter = _ChecklistFilter.all;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trip =
        widget.trip ??
        Trip(
          id: 'quick-trip',
          name: 'My trip',
          type: TripType.city,
          durationDays: 3,
          departureDate: DateTime.now(),
          travelerCount: 1,
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final checklist = context.read<ChecklistProvider>();
      checklist.selectTrip(_trip.id);
      if (widget.template != null) {
        checklist.applyTemplate(_trip, widget.template!);
      } else if (checklist.items.isEmpty) {
        checklist.generateChecklist(_trip);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ChecklistProvider>(
        builder: (context, checklist, _) {
          final visibleItems = _visibleItems(checklist.items);
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              SharedSiteHeader(
                selectedIndex: 0,
                onDestinationSelected: (index) {
                  Navigator.of(context).pushReplacementNamed(
                    index == 0 ? AppRoutes.home : AppRoutes.templates,
                  );
                },
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 880),
                  padding: EdgeInsets.fromLTRB(
                    AppLayout.gutter(context),
                    36,
                    AppLayout.gutter(context),
                    80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _backLink(),
                      ),
                      const SizedBox(height: 14),
                      _tripHeader(),
                      const SizedBox(height: 28),
                      _progressCard(checklist),
                      const SizedBox(height: 28),
                      _toolbar(),
                      const SizedBox(height: 14),
                      _categoryChips(checklist.items),
                      const SizedBox(height: 28),
                      _itemSheet(visibleItems, checklist),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _backLink() {
    return Tooltip(
      message: 'Go back',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        hoverColor: Colors.transparent,
        onTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, size: 18, color: _muted),
              SizedBox(width: 6),
              Text(
                'Your trips',
                style: TextStyle(
                  color: _muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionsMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Checklist actions',
      position: PopupMenuPosition.under,
      onSelected: (action) {
        if (action == 'generate') _showGenerateDialog();
        if (action == 'clear') _confirmRemovePacked();
        if (action == 'save-template') _saveAsTemplate();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'generate', child: Text('Regenerate checklist')),
        PopupMenuItem(value: 'clear', child: Text('Remove packed items')),
        PopupMenuItem(value: 'save-template', child: Text('Save as list')),
      ],
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.fieldBorder, width: 1.5),
        ),
        child: const Icon(Icons.more_horiz, color: AppColors.ink, size: 20),
      ),
    );
  }

  Widget _addItemButton() {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: () => _showItemEditor(),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add item'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
      ),
    );
  }

  Future<void> _saveAsTemplate() async {
    final name = await showTextPromptDialog(
      context,
      title: 'Save as template',
      label: 'Template name',
      confirmLabel: 'Save',
      initialText: _trip.name,
    );
    if (!mounted || name == null || name.trim().isEmpty) return;
    try {
      await context.read<TemplateProvider>().createTemplate(
        name: name,
        template: PackingTemplate(
          id: _trip.id,
          name: _trip.name,
          type: _trip.type,
        ),
        items: context.read<ChecklistProvider>().items,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Template saved.')));
    } catch (error) {
      debugPrint('Failed to save template: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the template.')),
      );
    }
  }

  Widget _tripHeader() {
    final date = _trip.departureDate;
    final travelers = _trip.travelerCount;
    final typeName = _trip.type.name;
    final subtitle =
        '${typeName[0].toUpperCase()}${typeName.substring(1)} trip · '
        'leaves ${_weekday(date.weekday)}, ${date.day} ${_month(date.month)} · '
        '${_trip.durationDays} days · '
        '$travelers ${travelers == 1 ? 'traveler' : 'travelers'}';
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _trip.name,
              style: AppText.display.copyWith(
                fontSize: 46,
                height: 1.08,
                letterSpacing: -0.92,
              ),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: _muted, fontSize: 16)),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionsMenu(),
            const SizedBox(width: 10),
            _addItemButton(),
          ],
        ),
      ],
    );
  }

  Widget _progressCard(ChecklistProvider checklist) {
    final percent = (checklist.progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${checklist.packedCount}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontFamily: AppText.serif,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' of ${checklist.totalCount} packed'),
                  ],
                ),
                style: const TextStyle(color: _muted, fontSize: 15),
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(color: _muted, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: checklist.progress,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _toolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = _searchField();
        final status = _statusChips();
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              search,
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: status,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            status,
          ],
        );
      },
    );
  }

  Widget _searchField() {
    OutlineInputBorder pill(Color color, [double width = 1.5]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: color, width: width),
        );
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            setState(() => _query = value.trim().toLowerCase()),
        style: const TextStyle(color: AppColors.ink, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search your checklist',
          hintStyle: const TextStyle(color: _muted, fontSize: 15),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 18, right: 10),
            child: Icon(Icons.search, color: _muted, size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(),
          contentPadding: const EdgeInsets.only(right: 18),
          border: pill(AppColors.fieldBorder),
          enabledBorder: pill(AppColors.fieldBorder),
          focusedBorder: pill(AppColors.primary, 2),
        ),
      ),
    );
  }

  Widget _statusChips() {
    const tabs = <(_ChecklistFilter, String)>[
      (_ChecklistFilter.all, 'All'),
      (_ChecklistFilter.toPack, 'To pack'),
      (_ChecklistFilter.packed, 'Packed'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE6DA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (filter, label) in tabs)
            _SegmentButton(
              label: label,
              selected: _statusFilter == filter,
              onPressed: () => setState(() => _statusFilter = filter),
            ),
        ],
      ),
    );
  }

  Widget _categoryChips(List<PackingItem> items) {
    final categories = <String>[
      'All',
      ...ChecklistProvider.categories.where(
        (category) => items.any((item) => item.category == category),
      ),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in categories)
          _CategoryChip(
            label: category,
            selected: _categoryFilter == category,
            onPressed: () => setState(() => _categoryFilter = category),
          ),
      ],
    );
  }

  List<PackingItem> _visibleItems(List<PackingItem> items) =>
      items.where((item) {
        final matchesQuery = item.name.toLowerCase().contains(_query);
        final matchesCategory =
            _categoryFilter == 'All' || item.category == _categoryFilter;
        final matchesStatus = switch (_statusFilter) {
          _ChecklistFilter.all => true,
          _ChecklistFilter.toPack => !item.isPacked,
          _ChecklistFilter.packed => item.isPacked,
        };
        return matchesQuery && matchesCategory && matchesStatus;
      }).toList();

  /// Visible items on one sheet, grouped under their category in the
  /// provider's category order (custom categories follow, as first seen).
  Widget _itemSheet(
    List<PackingItem> visibleItems,
    ChecklistProvider checklist,
  ) {
    final order = <String>{
      ...ChecklistProvider.categories,
      for (final item in checklist.items) item.category,
    };

    final groups = <Widget>[];
    for (final category in order) {
      final shown = visibleItems.where((i) => i.category == category).toList();
      if (shown.isEmpty) continue;
      final all = checklist.items.where((i) => i.category == category);
      final packed = all.where((i) => i.isPacked).length;
      groups.add(
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontFamily: AppText.serif,
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$packed of ${all.length}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              for (final item in shown)
                _ItemRow(
                  item: item,
                  onToggle: () => checklist.togglePacked(item.id),
                  onEdit: () => _showItemEditor(item),
                  onDelete: () => _confirmDelete(item),
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: groups.isEmpty
          ? _emptyResults()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: groups,
            ),
    );
  }

  Widget _emptyResults() => Padding(
    padding: const EdgeInsets.fromLTRB(0, 48, 0, 36),
    child: Column(
      children: [
        Text(
          _query.isNotEmpty ? 'No matching items' : 'Nothing here yet',
          style: const TextStyle(
            color: AppColors.ink,
            fontFamily: AppText.serif,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _query.isNotEmpty
              ? 'Try another search or filter.'
              : 'Add an item or generate a fresh checklist.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 15),
        ),
      ],
    ),
  );

  Future<void> _showItemEditor([PackingItem? item]) async {
    final draft = await showDialog<_ItemDraft>(
      context: context,
      builder: (_) => _ItemEditorDialog(item: item),
    );
    if (!mounted || draft == null) return;

    final checklist = context.read<ChecklistProvider>();
    if (item == null) {
      checklist.addItem(
        name: draft.name,
        category: draft.category,
        quantity: draft.quantity,
        isShared: draft.isShared,
      );
    } else {
      checklist.updateItem(
        PackingItem(
          id: item.id,
          tripId: item.tripId,
          travelerId: item.travelerId,
          name: draft.name,
          category: draft.category,
          quantity: draft.quantity,
          isPacked: item.isPacked,
          isShared: draft.isShared,
          isReturnItem: item.isReturnItem,
        ),
      );
    }
  }

  Future<void> _showGenerateDialog() async {
    final result = await showDialog<(TripType, int)>(
      context: context,
      builder: (_) => _GenerateDialog(
        initialType: _trip.type,
        initialDays: _trip.durationDays,
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      _trip = Trip(
        id: _trip.id,
        name: _trip.name,
        type: result.$1,
        durationDays: result.$2,
        departureDate: _trip.departureDate,
        travelerCount: _trip.travelerCount,
        reminderEnabled: _trip.reminderEnabled,
        reminderTime: _trip.reminderTime,
      );
      _categoryFilter = 'All';
      _statusFilter = _ChecklistFilter.all;
    });
    context.read<ChecklistProvider>().generateChecklist(_trip);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your checklist has been regenerated.')),
    );
  }

  Future<void> _confirmDelete(PackingItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove “${item.name}” from this checklist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) {
      context.read<ChecklistProvider>().removeItem(item.id);
    }
  }

  Future<void> _confirmRemovePacked() async {
    final checklist = context.read<ChecklistProvider>();
    if (checklist.packedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There are no packed items to remove.')),
      );
      return;
    }
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove packed items?'),
        content: Text(
          'This removes ${checklist.packedCount} packed ${checklist.packedCount == 1 ? 'item' : 'items'} from the checklist.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep them'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldRemove == true && mounted) {
      context.read<ChecklistProvider>().removePackedItems();
    }
  }

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  String _weekday(int weekday) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
}

enum _ChecklistFilter { all, toPack, packed }

/// What the item editor returns when the user saves.
class _ItemDraft {
  const _ItemDraft({
    required this.name,
    required this.category,
    required this.quantity,
    required this.isShared,
  });

  final String name;
  final String category;
  final int quantity;
  final bool isShared;
}

/// Add/edit packing item dialog. It owns its text controllers so they live
/// until the dialog is gone, including its closing animation.
class _ItemEditorDialog extends StatefulWidget {
  const _ItemEditorDialog({this.item});

  /// The item being edited, or null when adding a new one.
  final PackingItem? item;

  @override
  State<_ItemEditorDialog> createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<_ItemEditorDialog> {
  late final _nameController = TextEditingController(
    text: widget.item?.name ?? '',
  );
  late final _quantityController = TextEditingController(
    text: '${widget.item?.quantity ?? 1}',
  );
  late String _category = widget.item?.category ?? 'Clothing';
  late bool _isShared = widget.item?.isShared ?? false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      _ItemDraft(
        name: _nameController.text.trim(),
        category: _category,
        quantity: int.parse(_quantityController.text),
        isShared: _isShared,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.item == null ? 'Add packing item' : 'Edit packing item',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
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
                onChanged: (value) =>
                    setState(() => _category = value ?? 'Other'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  final quantity = int.tryParse(value ?? '');
                  return quantity == null || quantity < 1
                      ? 'Enter a quantity of at least 1'
                      : null;
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Shared item'),
                value: _isShared,
                onChanged: (value) => setState(() => _isShared = value),
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
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

/// "Generate checklist" dialog: trip type and duration. Owns its duration
/// controller for the same reason as [_ItemEditorDialog].
class _GenerateDialog extends StatefulWidget {
  const _GenerateDialog({required this.initialType, required this.initialDays});

  final TripType initialType;
  final int initialDays;

  @override
  State<_GenerateDialog> createState() => _GenerateDialogState();
}

class _GenerateDialogState extends State<_GenerateDialog> {
  late TripType _type = widget.initialType;
  late final _daysController = TextEditingController(
    text: '${widget.initialDays}',
  );

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate checklist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('What kind of trip are you packing for?'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<TripType>(
            initialValue: _type,
            borderRadius: BorderRadius.circular(20),
            decoration: const InputDecoration(labelText: 'Trip type'),
            items: TripType.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => _type = value ?? TripType.other),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _daysController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Trip duration (days)',
            ),
            validator: (value) {
              final days = int.tryParse(value ?? '');
              return days == null || days < 1 || days > 60
                  ? 'Enter a duration between 1 and 60 days'
                  : null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final days = int.tryParse(_daysController.text);
            if (days == null || days < 1 || days > 60) return;
            Navigator.pop(context, (_type, days));
          },
          child: const Text('Generate'),
        ),
      ],
    );
  }
}

/// One option in the All / To pack / Packed switch.
class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.surface : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.ink : AppColors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined category pill; filled dark when selected.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.ink : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.ink : AppColors.fieldBorder,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A checklist line: round checkbox, name (struck through once packed), an
/// optional "shared" note, quantity, and edit/delete buttons that brighten
/// when the row is hovered.
class _ItemRow extends StatefulWidget {
  const _ItemRow({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final PackingItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final packed = item.isPacked;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Semantics(
              checked: packed,
              label: item.name,
              child: GestureDetector(
                onTap: widget.onToggle,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: packed ? AppColors.packed : AppColors.surface,
                      border: Border.all(
                        color: packed
                            ? AppColors.packed
                            : const Color(0xFFB9AF9F),
                        width: 2,
                      ),
                    ),
                    child: packed
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: widget.onToggle,
                behavior: HitTestBehavior.opaque,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: packed ? AppColors.muted : AppColors.ink,
                        fontSize: 16,
                        decoration: packed ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.muted,
                      ),
                    ),
                    if (item.isShared)
                      const Text(
                        'shared',
                        style: TextStyle(
                          color: AppColors.shared,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 28),
              child: Text(
                '×${item.quantity}',
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.muted, fontSize: 15),
              ),
            ),
            const SizedBox(width: 14),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _hovered ? 1 : 0.55,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RowToolButton(
                    tooltip: 'Edit item',
                    icon: Icons.edit_outlined,
                    onPressed: widget.onEdit,
                  ),
                  const SizedBox(width: 2),
                  _RowToolButton(
                    tooltip: 'Delete item',
                    icon: Icons.delete_outline,
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowToolButton extends StatelessWidget {
  const _RowToolButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      color: AppColors.muted,
      hoverColor: AppColors.sand,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
    );
  }
}

extension on TripType {
  String get label => switch (this) {
    TripType.beach => 'Beach',
    TripType.business => 'Business',
    TripType.family => 'Family',
    TripType.camping => 'Camping',
    TripType.city => 'City break',
    TripType.other => 'Other',
  };
}
