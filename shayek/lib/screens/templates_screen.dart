import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/packing_template.dart';
import '../models/trip.dart';
import '../providers/template_provider.dart';
import '../providers/trip_provider.dart';
import 'template_editor_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  static const _background = Color(0xFFF9FAF6);
  static const _ink = Color(0xFF1A2925);
  static const _muted = Color(0xFF607168);
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TemplateProvider>().loadTemplates();
      context.read<TripProvider>().loadTrips();
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
      backgroundColor: _background,
      appBar: AppBar(
        toolbarHeight: 0,
        title: const Text('Lists'),
        backgroundColor: _background,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Consumer<TemplateProvider>(
                builder: (context, provider, _) {
                  final templates = provider.templates;
                  final ownLists = templates
                      .where((template) => !template.id.startsWith('sample-'))
                      .toList();
                  final publicLists = provider.publicLists.where((template) {
                    final query = _searchQuery.trim().toLowerCase();
                    return query.isEmpty ||
                        template.name.toLowerCase().contains(query) ||
                        template.type.name.contains(query) ||
                        template.items.any(
                          (item) => item.name.toLowerCase().contains(query),
                        );
                  }).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${templates.length} saved',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Lists',
                        style: TextStyle(
                          color: _ink,
                          fontFamily: 'Georgia',
                          fontSize: 38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _createTemplate,
                        icon: const Icon(Icons.add),
                        label: const Text('Create List'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF456F60),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : provider.errorMessage != null
                            ? _ErrorState(message: provider.errorMessage!)
                            : ListView(
                                padding: const EdgeInsets.only(bottom: 24),
                                children: [
                                  if (ownLists.isEmpty)
                                    _EmptyState(
                                      onCreateTemplate: _createTemplate,
                                      onStartTrip: _startTrip,
                                    )
                                  else ...[
                                    const Text(
                                      'Your Packing Lists',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  ...ownLists.map(
                                    (template) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: _TemplateCard(
                                        template: template,
                                        onUse: () => _attachList(template),
                                        onRename: () =>
                                            _renameTemplate(template),
                                        onDelete: () =>
                                            _deleteTemplate(template),
                                        onVisibilityChanged: (visibility) =>
                                            _changeVisibility(
                                              template,
                                              visibility,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Search Packing Lists',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                      hintText: 'Search by name, type, or item',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) =>
                                        setState(() => _searchQuery = value),
                                  ),
                                  const SizedBox(height: 16),
                                  if (publicLists.isEmpty)
                                    const Text(
                                      'No public lists match your search.',
                                      style: TextStyle(color: _muted),
                                    )
                                  else
                                    ...publicLists.map(
                                      (template) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        child: _TemplateCard(
                                          template: template,
                                          onUse: () => _attachList(template),
                                          onRename: () {},
                                          onDelete: () {},
                                          onVisibilityChanged: (_) {},
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startTrip() {
    Navigator.of(context).pushNamed(AppRoutes.createTrip);
  }

  Future<void> _attachList(PackingTemplate template) async {
    final tripProvider = context.read<TripProvider>();
    await tripProvider.loadTrips();
    if (!mounted) return;
    final trips = tripProvider.trips;
    if (trips.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a trip before attaching a list.')),
      );
      return;
    }
    final trip = await showDialog<Trip>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Attach list to a trip'),
        content: SizedBox(
          width: 420,
          child: ListView(
            shrinkWrap: true,
            children: trips
                .map(
                  (trip) => ListTile(
                    leading: const Icon(Icons.luggage_outlined),
                    title: Text(trip.name),
                    subtitle: Text(
                      '${trip.type.name} · ${trip.durationDays} days',
                    ),
                    onTap: () => Navigator.pop(dialogContext, trip),
                  ),
                )
                .toList(),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
    if (!mounted || trip == null) return;
    try {
      await context.read<TripProvider>().attachList(trip, template.id);
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRoutes.checklist,
        arguments: ChecklistRouteArgs(trip: trip, template: template),
      );
    } catch (error) {
      debugPrint('Failed to attach list: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not attach the list.')),
      );
    }
  }

  Future<void> _changeVisibility(
    PackingTemplate template,
    ListVisibility visibility,
  ) async {
    try {
      await context.read<TemplateProvider>().updateVisibility(
        template,
        visibility,
      );
    } catch (error) {
      debugPrint('Failed to update list visibility: $error');
    }
  }

  Future<void> _createTemplate() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: SizedBox(width: 720, child: TemplateEditorScreen(isModal: true)),
      ),
    );
  }

  Future<void> _renameTemplate(PackingTemplate template) async {
    final controller = TextEditingController(text: template.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename template'),
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
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.trim().isEmpty) return;
    try {
      await context.read<TemplateProvider>().renameTemplate(template, name);
    } catch (error) {
      debugPrint('Failed to rename template: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not rename the template.')),
      );
    }
  }

  Future<void> _deleteTemplate(PackingTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete template?'),
        content: Text('Delete "${template.name}" permanently?'),
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
    if (!mounted || confirmed != true) return;
    try {
      await context.read<TemplateProvider>().deleteTemplate(template);
    } catch (error) {
      debugPrint('Failed to delete template: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete the template.')),
      );
    }
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onUse,
    required this.onRename,
    required this.onDelete,
    required this.onVisibilityChanged,
  });

  final PackingTemplate template;
  final VoidCallback onUse;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final ValueChanged<ListVisibility> onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    final itemNames = template.items.map((item) => item.name).take(6).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE0E7E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFC5EAF6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.widgets_outlined,
                  color: Color(0xFF245565),
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _typeLabel(template.type),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A2925),
                        fontFamily: 'Georgia',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${template.items.length} items · ${template.visibility.name}',
                      style: const TextStyle(
                        color: Color(0xFF607168),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'List actions',
                onSelected: (action) {
                  if (action == 'rename') onRename();
                  if (action == 'delete') onDelete();
                  if (action == 'make-public') {
                    onVisibilityChanged(ListVisibility.public);
                  }
                  if (action == 'make-private') {
                    onVisibilityChanged(ListVisibility.private);
                  }
                },
                itemBuilder: (_) => [
                  if (!template.isDiscoverable)
                    const PopupMenuItem(
                      value: 'make-public',
                      child: Text('Make public'),
                    ),
                  if (template.isDiscoverable)
                    const PopupMenuItem(
                      value: 'make-private',
                      child: Text('Make private'),
                    ),
                  if (!template.id.startsWith('sample-')) ...[
                    const PopupMenuItem(value: 'rename', child: Text('Rename')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ],
              ),
            ],
          ),
          if (itemNames.isNotEmpty) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: itemNames
                    .map(
                      (itemName) => Chip(
                        label: Text(itemName),
                        backgroundColor: const Color(0xFFDCECE2),
                        labelStyle: const TextStyle(
                          color: Color(0xFF456F60),
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onUse,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A2925),
                side: const BorderSide(color: Color(0xFFDCE4DE)),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Use List',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _typeLabel(TripType type) =>
      type.name[0].toUpperCase() + type.name.substring(1);
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onCreateTemplate,
    required this.onStartTrip,
  });

  final VoidCallback onCreateTemplate;
  final VoidCallback onStartTrip;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 44),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE0E7E1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 54,
            backgroundColor: Color(0xFFDCECE2),
            child: Icon(
              Icons.widgets_outlined,
              size: 48,
              color: Color(0xFF456F60),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'No saved templates yet',
            style: TextStyle(
              color: Color(0xFF1A2925),
              fontFamily: 'Georgia',
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Save any packing list as a template to reuse it on your next trip in one tap.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF607168),
              fontSize: 17,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreateTemplate,
            icon: const Icon(Icons.add),
            label: const Text('Create Template'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF456F60),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onStartTrip,
            child: const Text('Or start a trip'),
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(message, style: const TextStyle(color: Colors.red)),
  );
}
