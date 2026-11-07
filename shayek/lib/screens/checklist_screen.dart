import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/packing_item.dart';
import '../models/trip.dart';
import '../providers/checklist_provider.dart';
import '../widgets/shared_bottom_navigation_bar.dart';

/// Checklist generation and management screen for a trip.
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key, this.trip});

  final Trip? trip;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  static const _green = Color(0xFF185C45);
  static const _muted = Color(0xFF607168);

  late Trip _trip;
  String _query = '';
  String _categoryFilter = 'All';
  _ChecklistFilter _statusFilter = _ChecklistFilter.all;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trip = widget.trip ??
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
      if (checklist.items.isEmpty) checklist.generateChecklist(_trip);
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
      backgroundColor: const Color(0xFFF8F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F5),
        title: const Text('Packing checklist'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Checklist actions',
            onSelected: (action) {
              if (action == 'generate') _showGenerateDialog();
              if (action == 'clear') _confirmRemovePacked();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'generate', child: Text('Regenerate checklist')),
              PopupMenuItem(value: 'clear', child: Text('Remove packed items')),
            ],
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklist, _) {
          final visibleItems = _visibleItems(checklist.items);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _tripHeader(),
              const SizedBox(height: 18),
              _progressCard(checklist),
              const SizedBox(height: 22),
              _sectionTitle(checklist.items.length),
              const SizedBox(height: 12),
              _searchField(),
              const SizedBox(height: 14),
              _statusChips(checklist),
              const SizedBox(height: 12),
              _categoryChips(checklist.items),
              const SizedBox(height: 12),
              if (visibleItems.isEmpty)
                _emptyResults()
              else
                ...visibleItems.map((item) => _itemCard(item, checklist)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemEditor(),
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      bottomNavigationBar: SharedBottomNavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.templates);
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }
        },
      ),
    );
  }

  Widget _tripHeader() {
    final date = _trip.departureDate;
    final dateLabel = '${_month(date.month)} ${date.day}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.luggage_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _trip.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_trip.type.label}  ·  ${_trip.durationDays} days  ·  ${_trip.travelerCount} ${_trip.travelerCount == 1 ? 'traveler' : 'travelers'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text('Departing $dateLabel', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: _showGenerateDialog,
            tooltip: 'Trip packing settings',
            color: Colors.white,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(ChecklistProvider checklist) {
    final percent = (checklist.progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Packing progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              Text('$percent%', style: const TextStyle(color: _green, fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: checklist.progress,
              minHeight: 9,
              backgroundColor: const Color(0xFFE8ECE7),
              color: _green,
            ),
          ),
          const SizedBox(height: 10),
          Text('${checklist.packedCount} of ${checklist.totalCount} items packed', style: const TextStyle(color: _muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _sectionTitle(int count) => Row(
        children: [
          const Expanded(
            child: Text('Your items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          Text('$count items', style: const TextStyle(color: _muted, fontSize: 13)),
        ],
      );

  Widget _searchField() => TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search your checklist',
          prefixIcon: const Icon(Icons.search, color: _muted),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE7EAE5)),
          ),
        ),
      );

  Widget _statusChips(ChecklistProvider checklist) {
    final tabs = <(_ChecklistFilter, String)>[
      (_ChecklistFilter.all, 'All (${checklist.totalCount})'),
      (_ChecklistFilter.toPack, 'To pack (${checklist.totalCount - checklist.packedCount})'),
      (_ChecklistFilter.packed, 'Packed (${checklist.packedCount})'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final selected = _statusFilter == tab.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tab.$2),
              selected: selected,
              onSelected: (_) => setState(() => _statusFilter = tab.$1),
              selectedColor: const Color(0xFFE0ECE5),
              labelStyle: TextStyle(color: selected ? _green : _muted, fontWeight: FontWeight.w600),
              side: BorderSide(color: selected ? const Color(0xFFB7CCBF) : const Color(0xFFE7EAE5)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _categoryChips(List<PackingItem> items) {
    final categories = <String>['All', ...ChecklistProvider.categories.where((category) => items.any((item) => item.category == category))];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected = _categoryFilter == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => setState(() => _categoryFilter = category),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFE0ECE5),
              checkmarkColor: _green,
              side: const BorderSide(color: Color(0xFFE7EAE5)),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<PackingItem> _visibleItems(List<PackingItem> items) => items.where((item) {
        final matchesQuery = item.name.toLowerCase().contains(_query);
        final matchesCategory = _categoryFilter == 'All' || item.category == _categoryFilter;
        final matchesStatus = switch (_statusFilter) {
          _ChecklistFilter.all => true,
          _ChecklistFilter.toPack => !item.isPacked,
          _ChecklistFilter.packed => item.isPacked,
        };
        return matchesQuery && matchesCategory && matchesStatus;
      }).toList();

  Widget _itemCard(PackingItem item, ChecklistProvider checklist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE7EAE5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
        child: Row(
          children: [
            Checkbox(
              value: item.isPacked,
              activeColor: _green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onChanged: (_) => checklist.togglePacked(item.id),
            ),
            Expanded(
              child: InkWell(
                onTap: () => checklist.togglePacked(item.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          decoration: item.isPacked ? TextDecoration.lineThrough : null,
                          color: item.isPacked ? _muted : const Color(0xFF252A27),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _categoryIcon(item.category, size: 14),
                          const SizedBox(width: 5),
                          Text(item.category, style: const TextStyle(color: _muted, fontSize: 12)),
                          if (item.quantity > 1) ...[
                            const SizedBox(width: 9),
                            Text('Qty ${item.quantity}', style: const TextStyle(color: _muted, fontSize: 12)),
                          ],
                          if (item.isShared) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.people_outline, size: 14, color: _muted),
                            const SizedBox(width: 3),
                            const Text('Shared', style: TextStyle(color: _muted, fontSize: 12)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Item actions',
              onSelected: (action) {
                if (action == 'edit') _showItemEditor(item);
                if (action == 'delete') _confirmDelete(item);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit item')),
                PopupMenuItem(value: 'delete', child: Text('Delete item')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyResults() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7EAE5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.checklist_outlined, size: 38, color: _muted),
            const SizedBox(height: 10),
            Text(
              _query.isNotEmpty ? 'No matching items' : 'Nothing here yet',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              _query.isNotEmpty ? 'Try another search or filter.' : 'Add an item or generate a fresh checklist.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13),
            ),
          ],
        ),
      );

  Future<void> _showItemEditor([PackingItem? item]) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final quantityController = TextEditingController(text: '${item?.quantity ?? 1}');
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
                    validator: (value) => value == null || value.trim().isEmpty ? 'Enter an item name' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ChecklistProvider.categories
                        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) => setDialogState(() => category = value ?? 'Other'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (value) {
                      final quantity = int.tryParse(value ?? '');
                      return quantity == null || quantity < 1 ? 'Enter a quantity of at least 1' : null;
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Shared item'),
                    value: isShared,
                    onChanged: (value) => setDialogState(() => isShared = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) Navigator.pop(dialogContext, true);
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
        checklist.addItem(name: name, category: category, quantity: quantity, isShared: isShared);
      } else {
        checklist.updateItem(PackingItem(
          id: item.id,
          tripId: item.tripId,
          travelerId: item.travelerId,
          name: name,
          category: category,
          quantity: quantity,
          isPacked: item.isPacked,
          isShared: isShared,
          isReturnItem: item.isReturnItem,
        ));
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
              const Align(alignment: Alignment.centerLeft, child: Text('What kind of trip are you packing for?')),
              const SizedBox(height: 10),
              DropdownButtonFormField<TripType>(
                value: type,
                decoration: const InputDecoration(labelText: 'Trip type'),
                items: TripType.values
                    .map((value) => DropdownMenuItem(value: value, child: Text(value.label)))
                    .toList(),
                onChanged: (value) => setDialogState(() => type = value ?? TripType.other),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Trip duration (days)'),
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
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your checklist has been regenerated.')));
  }

  Future<void> _confirmDelete(PackingItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove “${item.name}” from this checklist?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('There are no packed items to remove.')));
      return;
    }
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove packed items?'),
        content: Text('This removes ${checklist.packedCount} packed ${checklist.packedCount == 1 ? 'item' : 'items'} from the checklist.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep them')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Remove')),
        ],
      ),
    );
    if (shouldRemove == true && mounted) {
      context.read<ChecklistProvider>().removePackedItems();
    }
  }

  String _month(int month) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
