import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/packing_template.dart';
import '../models/trip.dart';
import '../providers/template_provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/text_prompt_dialog.dart';
import 'template_editor_screen.dart';

/// Opens the "Create a packing list" editor as a dialog. Used by the Lists
/// empty state and by the "Create list" button in the top bar.
Future<void> showCreateListDialog(BuildContext context) {
  return showDialog<void>(
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
    return ColoredBox(
      color: _background,
      child: Consumer<TemplateProvider>(
        builder: (context, provider, _) {
          final ownLists = provider.templates
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

          return ListView(
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.pageWidth,
                  ),
                  padding: EdgeInsets.fromLTRB(
                    AppLayout.gutter(context),
                    56,
                    AppLayout.gutter(context),
                    80,
                  ),
                  child: provider.isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.errorMessage != null
                      ? _ErrorState(message: provider.errorMessage!)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const HighlightedHeading(
                              before: 'Your packing ',
                              highlighted: 'lists',
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Lists you’ve saved, ready to reuse on your next trip.',
                              style: AppText.lead,
                            ),
                            const SizedBox(height: 28),
                            if (ownLists.isEmpty)
                              _EmptyState(
                                onCreateTemplate: _createTemplate,
                                onStartTrip: _startTrip,
                              )
                            else
                              _CardGrid(
                                children: [
                                  for (final template in ownLists)
                                    _TemplateCard(
                                      template: template,
                                      onUse: () => _attachList(template),
                                      onRename: () => _renameTemplate(template),
                                      onDelete: () => _deleteTemplate(template),
                                      onVisibilityChanged: (visibility) =>
                                          _changeVisibility(
                                            template,
                                            visibility,
                                          ),
                                    ),
                                ],
                              ),
                            const SizedBox(height: 56),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.line,
                            ),
                            const SizedBox(height: 48),
                            _searchHeader(),
                            const SizedBox(height: 20),
                            if (publicLists.isEmpty)
                              const Text(
                                'No public lists match your search.',
                                style: TextStyle(color: _muted, fontSize: 15),
                              )
                            else
                              _PublicListResults(
                                lists: publicLists,
                                onUse: _attachList,
                              ),
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

  Widget _searchHeader() {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Search packing lists', style: AppText.title),
        const SizedBox(height: 8),
        Text(
          'Borrow a list other travelers have made public.',
          style: AppText.lead.copyWith(fontSize: 16),
        ),
      ],
    );
    final search = SizedBox(
      height: 52,
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.ink, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search by name, type, or item',
          hintStyle: const TextStyle(color: _muted, fontSize: 16),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 20, right: 10),
            child: Icon(Icons.search, color: _muted, size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(),
          contentPadding: const EdgeInsets.only(right: 20),
          border: _pillBorder(AppColors.fieldBorder),
          enabledBorder: _pillBorder(AppColors.fieldBorder),
          focusedBorder: _pillBorder(AppColors.primary, 2),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, const SizedBox(height: 20), search],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: title),
            const SizedBox(width: 20),
            SizedBox(width: 420, child: search),
          ],
        );
      },
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

  Future<void> _createTemplate() => showCreateListDialog(context);

  Future<void> _renameTemplate(PackingTemplate template) async {
    final name = await showTextPromptDialog(
      context,
      title: 'Rename template',
      label: 'Template name',
      confirmLabel: 'Rename',
      initialText: template.name,
    );
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

/// Lays cards out in equal columns at least 330px wide (up to three).
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 24.0;
        final width = constraints.maxWidth;
        final columns = ((width + spacing) / (330 + spacing)).floor().clamp(
          1,
          3,
        );
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

String _typeLabel(TripType type) =>
    type.name[0].toUpperCase() + type.name.substring(1);

/// Outlined "Use list" pill that fills dark on hover.
class _UseListButton extends StatelessWidget {
  const _UseListButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.ink, width: 1.5),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: AppText.sans,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? Colors.white
              : AppColors.ink,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? AppColors.ink
              : Colors.transparent,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      child: const Text('Use list'),
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
    final names = template.items.map((item) => item.name).toList();
    final shown = names.take(5).join(', ');
    final more = names.length - 5;
    final colors = TripTypeColors.of(template.type);
    final isPublic = template.visibility == ListVisibility.public;

    return Container(
      padding: const EdgeInsets.all(24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.type.name.toUpperCase(),
                      style: AppText.eyebrow(colors.onTint),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      template.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.cardTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox.square(
                dimension: 40,
                child: PopupMenuButton<String>(
                  tooltip: 'List actions',
                  padding: EdgeInsets.zero,
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
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (names.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: shown),
                  if (more > 0)
                    TextSpan(
                      text: ' + $more more',
                      style: const TextStyle(color: AppColors.ink),
                    ),
                ],
              ),
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Icon(
                  isPublic ? Icons.public : Icons.lock_outline,
                  size: 15,
                  color: isPublic ? AppColors.shared : AppColors.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isPublic ? 'Public' : 'Private',
                    style: TextStyle(
                      color: isPublic ? AppColors.shared : AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ),
                _UseListButton(onPressed: onUse),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Public lists as rows on one sheet: name, type, size, and a few items.
class _PublicListResults extends StatelessWidget {
  const _PublicListResults({required this.lists, required this.onUse});

  final List<PackingTemplate> lists;
  final ValueChanged<PackingTemplate> onUse;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          for (final (index, template) in lists.indexed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                border: index == lists.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppColors.divider),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: AppText.cardTitle.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _summary(template),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  _UseListButton(onPressed: () => onUse(template)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _summary(PackingTemplate template) {
    final names = template.items.map((item) => item.name).toList();
    final count = '${names.length} item${names.length == 1 ? '' : 's'}';
    final preview = names.take(3).join(', ');
    final ellipsis = names.length > 3 ? '…' : '';
    return [
      _typeLabel(template.type),
      count,
      if (preview.isNotEmpty) '$preview$ellipsis',
    ].join(' · ');
  }
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
    padding: const EdgeInsets.fromLTRB(24, 44, 24, 36),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No saved templates yet',
          style: AppText.cardTitle.copyWith(fontSize: 26),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Save any packing list as a template to reuse it on your next trip in one tap.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 16, height: 1.55),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onCreateTemplate,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create Template'),
        ),
        const SizedBox(height: 8),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 80),
    child: Center(
      child: Text(message, style: const TextStyle(color: AppColors.error)),
    ),
  );
}
