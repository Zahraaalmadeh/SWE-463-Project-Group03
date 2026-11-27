import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/packing_item.dart';
import '../models/trip.dart';
import '../providers/checklist_provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/page_scaffold.dart';

/// Things to collect before leaving the accommodation, plus the trip's
/// departure reminder. The reminder is shown as a banner on Home on the day
/// before and the day of departure.
class ReturnChecklistScreen extends StatefulWidget {
  const ReturnChecklistScreen({super.key, this.trip});

  final Trip? trip;

  @override
  State<ReturnChecklistScreen> createState() => _ReturnChecklistScreenState();
}

class _ReturnChecklistScreenState extends State<ReturnChecklistScreen> {
  final _itemController = TextEditingController();
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    _reminderEnabled = trip?.reminderEnabled ?? false;
    if (trip?.reminderTime != null) {
      final reminder = trip!.reminderTime!;
      _reminderTime = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || trip == null) return;
      final checklist = context.read<ChecklistProvider>();
      checklist.selectTrip(trip.id);
      await checklist.loadItems(trip.id);
      if (!mounted) return;
      checklist.ensureReturnChecklist(trip);
    });
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (selected != null && mounted) {
      setState(() => _reminderTime = selected);
      await _saveReminder();
    }
  }

  Future<void> _saveReminder() async {
    final trip = widget.trip;
    if (trip == null) return;
    final now = DateTime.now();
    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      _reminderTime.hour,
      _reminderTime.minute,
    );
    try {
      await context.read<TripProvider>().updateReminder(
        tripId: trip.id,
        enabled: _reminderEnabled,
        reminderTime: reminderTime,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the reminder. Please try again.'),
        ),
      );
    }
  }

  void _addItem(ChecklistProvider checklist) {
    final name = _itemController.text;
    try {
      checklist.addReturnItem(name: name);
      _itemController.clear();
    } on ArgumentError {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a return item')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    if (trip == null) {
      return const PageScaffold(
        backLabel: 'Back',
        title: 'Return checklist',
        child: PageMessage(
          title: 'No trip selected',
          message: 'Open the Return checklist from one of your trips.',
        ),
      );
    }

    return PageScaffold(
      backLabel: 'Back',
      title: 'Return checklist',
      subtitle: '${trip.name} · things to collect before you head home.',
      child: Consumer<ChecklistProvider>(
        builder: (context, checklist, _) {
          final items = checklist.returnItems;
          final packed = items.where((item) => item.isPacked).length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReminderCard(
                enabled: _reminderEnabled,
                time: _reminderTime.format(context),
                onChanged: (value) {
                  setState(() => _reminderEnabled = value);
                  _saveReminder();
                },
                onPickTime: _pickReminderTime,
              ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Before you leave',
                    style: AppText.cardTitle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$packed of ${items.length} collected',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              PillInputRow(
                controller: _itemController,
                hint: 'Add a return item, e.g. Room key',
                buttonLabel: 'Add',
                onSubmit: () => _addItem(checklist),
              ),
              const SizedBox(height: 14),
              if (checklist.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: InlineError(message: checklist.errorMessage!),
                ),
              if (checklist.isLoading && items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                const PageMessage(
                  title: 'No return items yet',
                  message: 'Add things to collect before you check out.',
                )
              else
                SheetCard(
                  children: [
                    for (final item in items)
                      _ReturnItemRow(
                        item: item,
                        onToggle: () => checklist.togglePacked(item.id),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.enabled,
    required this.time,
    required this.onChanged,
    required this.onPickTime,
  });

  final bool enabled;
  final String time;
  final ValueChanged<bool> onChanged;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Departure reminder', style: AppText.label),
                    const SizedBox(height: 2),
                    Text(
                      enabled
                          ? 'Set for $time · shown on Home the day before '
                                'and the day you leave'
                          : 'Off',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: enabled, onChanged: onChanged),
            ],
          ),
          if (enabled)
            Padding(
              padding: const EdgeInsets.only(left: 38, top: 8),
              child: OutlinedButton.icon(
                onPressed: onPickTime,
                icon: const Icon(Icons.schedule, size: 18),
                label: Text('Change time ($time)'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReturnItemRow extends StatelessWidget {
  const _ReturnItemRow({required this.item, required this.onToggle});

  final PackingItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Checkbox(value: item.isPacked, onChanged: (_) => onToggle()),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  color: item.isPacked ? AppColors.muted : AppColors.ink,
                  fontSize: 16,
                  decoration: item.isPacked ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
