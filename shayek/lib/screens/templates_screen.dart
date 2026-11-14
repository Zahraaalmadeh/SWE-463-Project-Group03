import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/packing_template.dart';
import '../models/trip.dart';
import '../providers/template_provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import 'template_editor_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  static const _background = AppColors.background;
  static const _muted = AppColors.muted;
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
            constraints: const BoxConstraints(maxWidth: 1160),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 0),
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
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 24,
                        runSpacing: 16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${templates.length} saved',
                                style: AppText.lead,
                              ),
                              const SizedBox(height: 6),
                              const Text('Your Lists', style: AppText.display),
                            ],
                          ),
                          FilledButton.icon(
                            onPressed: _createTemplate,
                            icon: const Icon(Icons.add),
                            label: const Text('Create List'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : provider.errorMessage != null
                            ? _ErrorState(message: provider.errorMessage!)
                            : ListView(
                                padding: const EdgeInsets.only(bottom: 40),
                                children: [
                                  if (ownLists.isEmpty)
                                    _EmptyState(
                                      onCreateTemplate: _createTemplate,
                                      onStartTrip: _startTrip,
                                    )
                                  else ...[
                                    const Text(
                                      'Your Packing Lists',
                                      style: AppText.title,
                                    ),
                                    const SizedBox(height: 16),
                                    _CardGrid(
                                      children: [
                                        for (final template in ownLists)
                                          _TemplateCard(
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
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 44),
                                  const Divider(color: AppColors.line),
                                  const SizedBox(height: 36),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 24,
                                    runSpacing: 16,
                                    children: [
                                      const Text(
                                        'Search Packing Lists',
                                        style: AppText.title,
                                      ),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 420,
                                        ),
                                        child: TextField(
                                          controller: _searchController,
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(
                                              Icons.search,
                                              color: _muted,
                                            ),
                                            hintText:
                                                'Search by name, type, or item',
                                            border: _pillBorder(
                                              AppColors.fieldBorder,
                                            ),
                                            enabledBorder: _pillBorder(
                                              AppColors.fieldBorder,
                                            ),
                                            focusedBorder: _pillBorder(
                                              AppColors.primary,
                                              2,
                                            ),
                                          ),
                                          onChanged: (value) => setState(
                                            () => _searchQuery = value,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  if (publicLists.isEmpty)
                                    const Text(
                                      'No public lists match your search.',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 15,
                                      ),
                                    )
                                  else
                                    _CardGrid(
                                      children: [
                                        for (final template in publicLists)
                                          _TemplateCard(
                                            template: template,
                                            onUse: () => _attachList(template),
                                            onRename: () {},
                                            onDelete: () {},
                                            onVisibilityChanged: (_) {},
                                          ),
                                      ],
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

  static OutlineInputBorder _pillBorder(Color color, [double width = 1.5]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(99),
        borderSide: BorderSide(color: color, width: width),
      );

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
          borderRadius: BorderRadius.all(Radius.circular(22)),
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

/// Lays cards out in up to three equal columns, one column on narrow windows.
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 24.0;
        final width = constraints.maxWidth;
        final columns = width >= 1000
            ? 3
            : width >= 640
            ? 2
            : 1;
        final cardWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: cardWidth, child: child),
          ],
        );
      },
    );
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
    final colors = TripTypeColors.of(template.type);
    final isPublic = template.visibility == ListVisibility.public;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typeLabel(template.type),
                        style: AppText.eyebrow(colors.onTint),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        template.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.cardTitle.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'List actions',
                icon: const Icon(Icons.more_horiz, color: AppColors.muted),
                position: PopupMenuPosition.under,
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
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final itemName in itemNames)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        itemName,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Icon(
                  isPublic ? Icons.public : Icons.lock_outline,
                  size: 16,
                  color: isPublic ? AppColors.shared : AppColors.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${template.items.length} items · ${template.visibility.name}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ),
                OutlinedButton(onPressed: onUse, child: const Text('Use List')),
              ],
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
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.fieldBorder, width: 1.5),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.checklist_rtl_outlined,
            size: 32,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'No saved templates yet',
          style: AppText.title,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Save any packing list as a template to reuse it on your next trip in one tap.',
          textAlign: TextAlign.center,
          style: AppText.lead,
        ),
        const SizedBox(height: 26),
        FilledButton.icon(
          onPressed: onCreateTemplate,
          icon: const Icon(Icons.add),
          label: const Text('Create Template'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onStartTrip,
          child: const Text('Or start a trip'),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(message, style: const TextStyle(color: AppColors.error)),
  );
}
