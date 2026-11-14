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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Padding(
                    // Bottom padding keeps the last rows clear of the
                    // floating "Add item" button.
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _topBar(),
                        const SizedBox(height: 18),
                        _tripHeader(),
                        const SizedBox(height: 28),
                        _progressCard(checklist),
                        const SizedBox(height: 36),
                        _sectionTitle(checklist.items.length),
                        const SizedBox(height: 14),
                        _searchField(),
                        const SizedBox(height: 14),
                        _statusChips(checklist),
                        const SizedBox(height: 10),
                        _categoryChips(checklist.items),
                        const SizedBox(height: 18),
                        if (visibleItems.isEmpty)
                          _emptyResults()
                        else
                          _itemList(visibleItems, checklist),
                      ],
                    ),
                  ),
                ),
              ),
              const SiteFooter(),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 12, bottom: 12),
        child: FloatingActionButton.extended(
          onPressed: () => _showItemEditor(),
          icon: const Icon(Icons.add),
          label: const Text('Add item'),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        _CircleIconButton(
          tooltip: 'Go back',
          icon: Icons.arrow_back,
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            }
          },
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Packing checklist',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Checklist actions',
          position: PopupMenuPosition.under,
          onSelected: (action) {
            if (action == 'generate') _showGenerateDialog();
            if (action == 'clear') _confirmRemovePacked();
            if (action == 'save-template') _saveAsTemplate();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'generate',
              child: Text('Regenerate checklist'),
            ),
            PopupMenuItem(value: 'clear', child: Text('Remove packed items')),
            PopupMenuItem(value: 'save-template', child: Text('Save as list')),
          ],
          child: const _CircleIcon(icon: Icons.more_horiz),
        ),
      ],
    );
  }

  Future<void> _saveAsTemplate() async {
    final controller = TextEditingController(text: _trip.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save as template'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Template name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
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
    final dateLabel = '${_month(date.month)} ${date.day}';
    final colors = TripTypeColors.of(_trip.type);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_trip.type.label, style: AppText.eyebrow(colors.onTint)),
              const SizedBox(height: 8),
              Text(
                _trip.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.display,
              ),
              const SizedBox(height: 10),
              Text(
                '${_trip.durationDays} days  ·  ${_trip.travelerCount} ${_trip.travelerCount == 1 ? 'traveler' : 'travelers'}  ·  Departing $dateLabel',
                style: AppText.lead.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _CircleIconButton(
          tooltip: 'Trip packing settings',
          icon: Icons.tune,
          onPressed: _showGenerateDialog,
        ),
      ],
    );
  }

  Widget _progressCard(ChecklistProvider checklist) {
    final percent = (checklist.progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Expanded(
              child: Text('Packing progress', style: AppText.label),
            ),
            Text(
              '$percent%',
              style: AppText.cardTitle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: checklist.progress,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${checklist.packedCount} of ${checklist.totalCount} items packed',
          style: AppText.muted,
        ),
      ],
    );
  }

  Widget _sectionTitle(int count) => Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      const Expanded(child: Text('Your items', style: AppText.title)),
      Text('$count items', style: AppText.muted),
    ],
  );

  Widget _searchField() => TextField(
    controller: _searchController,
    onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
    decoration: InputDecoration(
      hintText: 'Search your checklist',
      prefixIcon: const Icon(Icons.search, color: _muted),
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(99),
        borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(99),
        borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(99),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );

  Widget _statusChips(ChecklistProvider checklist) {
    final tabs = <(_ChecklistFilter, String)>[
      (_ChecklistFilter.all, 'All (${checklist.totalCount})'),
      (
        _ChecklistFilter.toPack,
        'To pack (${checklist.totalCount - checklist.packedCount})',
      ),
      (_ChecklistFilter.packed, 'Packed (${checklist.packedCount})'),
    ];
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFEDE6DA),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: tabs.map((tab) {
                final selected = _statusFilter == tab.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: ChoiceChip(
                    label: Text(tab.$2),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _statusFilter = tab.$1),
                    backgroundColor: Colors.transparent,
                    selectedColor: AppColors.surface,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.ink : _muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
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
      children: categories.map((category) {
        final selected = _categoryFilter == category;
        return FilterChip(
          label: Text(category),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) => setState(() => _categoryFilter = category),
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.ink,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
          side: BorderSide(
            color: selected ? AppColors.ink : AppColors.fieldBorder,
            width: 1.5,
          ),
        );
      }).toList(),
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

  /// All visible items on one sheet, like a written packing list.
  Widget _itemList(List<PackingItem> items, ChecklistProvider checklist) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          for (final (index, item) in items.indexed) ...[
            if (index > 0)
              const Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: AppColors.divider,
              ),
            _itemRow(item, checklist),
          ],
        ],
      ),
    );
  }

  Widget _itemRow(PackingItem item, ChecklistProvider checklist) {
    return InkWell(
      onTap: () => checklist.togglePacked(item.id),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
        child: Row(
          children: [
            Checkbox(
              value: item.isPacked,
              onChanged: (_) => checklist.togglePacked(item.id),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: item.isPacked
                          ? TextDecoration.lineThrough
                          : null,
                      color: item.isPacked ? _muted : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 12,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _categoryIcon(item.category, size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.quantity > 1)
                        Text(
                          'Qty ${item.quantity}',
                          style: const TextStyle(color: _muted, fontSize: 13),
                        ),
                      if (item.isShared)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 14,
                              color: AppColors.shared,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Shared',
                              style: TextStyle(
                                color: AppColors.shared,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showItemEditor(item),
              tooltip: 'Edit item',
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: _muted,
            ),
            IconButton(
              onPressed: () => _confirmDelete(item),
              tooltip: 'Delete item',
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyResults() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.fieldBorder, width: 1.5),
    ),
    child: Column(
      children: [
        const Icon(Icons.checklist_outlined, size: 36, color: AppColors.accent),
        const SizedBox(height: 12),
        Text(
          _query.isNotEmpty ? 'No matching items' : 'Nothing here yet',
          style: AppText.cardTitle,
        ),
        const SizedBox(height: 6),
        Text(
          _query.isNotEmpty
              ? 'Try another search or filter.'
              : 'Add an item or generate a fresh checklist.',
          textAlign: TextAlign.center,
          style: AppText.muted.copyWith(fontSize: 15),
        ),
      ],
    ),
  );

  Future<void> _showItemEditor([PackingItem? item]) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final quantityController = TextEditingController(
      text: '${item?.quantity ?? 1}',
    );
    var category = item?.category ?? 'Clothing';
    var isShared = item?.isShared ?? false;
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add packing item' : 'Edit packing item'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Item name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter an item name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    borderRadius: BorderRadius.circular(20),
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ChecklistProvider.categories
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => category = value ?? 'Other'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: quantityController,
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
                    value: isShared,
                    onChanged: (value) =>
                        setDialogState(() => isShared = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) {
      nameController.dispose();
      quantityController.dispose();
      return;
    }
    if (saved == true) {
      final checklist = context.read<ChecklistProvider>();
      final name = nameController.text.trim();
      final quantity = int.parse(quantityController.text);
      if (item == null) {
        checklist.addItem(
          name: name,
          category: category,
          quantity: quantity,
          isShared: isShared,
        );
      } else {
        checklist.updateItem(
          PackingItem(
            id: item.id,
            tripId: item.tripId,
            travelerId: item.travelerId,
            name: name,
            category: category,
            quantity: quantity,
            isPacked: item.isPacked,
            isShared: isShared,
            isReturnItem: item.isReturnItem,
          ),
        );
      }
    }
    nameController.dispose();
    quantityController.dispose();
  }

  Future<void> _showGenerateDialog() async {
    var type = _trip.type;
    final daysController = TextEditingController(text: '${_trip.durationDays}');
    final result = await showDialog<(TripType, int)?>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                initialValue: type,
                borderRadius: BorderRadius.circular(20),
                decoration: const InputDecoration(labelText: 'Trip type'),
                items: TripType.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => type = value ?? TripType.other),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: daysController,
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final days = int.tryParse(daysController.text);
                if (days == null || days < 1 || days > 60) return;
                Navigator.pop(dialogContext, (type, days));
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
    daysController.dispose();
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

  Widget _categoryIcon(String category, {double size = 20}) {
    final icon = switch (category) {
      'Clothing' => Icons.checkroom_outlined,
      'Toiletries' => Icons.spa_outlined,
      'Documents' => Icons.description_outlined,
      'Electronics' => Icons.devices_outlined,
      'Essentials' => Icons.star_outline,
      'Activities' => Icons.hiking_outlined,
      _ => Icons.category_outlined,
    };
    return Icon(icon, size: size, color: _muted);
  }
}

enum _ChecklistFilter { all, toPack, packed }

/// Round outlined icon used for the back button and header actions.
class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.fieldBorder, width: 1.5),
      ),
      child: Icon(icon, color: AppColors.ink, size: 20),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Semantics(
            button: true,
            label: tooltip,
            child: _CircleIcon(icon: icon),
          ),
        ),
      ),
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
