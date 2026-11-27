import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/checklist_provider.dart';
import '../providers/trip_provider.dart';

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
    await context.read<TripProvider>().updateReminder(
      tripId: trip.id,
      enabled: _reminderEnabled,
      reminderTime: reminderTime,
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Return Checklist')),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklist, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (trip != null)
                Text(trip.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text('Departure reminder'),
                  subtitle: Text(
                    _reminderEnabled
                        ? 'Reminder set for ${_reminderTime.format(context)}'
                        : 'No reminder set',
                  ),
                  value: _reminderEnabled,
                  onChanged: (value) {
                    setState(() => _reminderEnabled = value);
                    _saveReminder();
                  },
                ),
              ),
              if (_reminderEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: _pickReminderTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      'Reminder time: ${_reminderTime.format(context)}',
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _itemController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addItem(checklist),
                      decoration: const InputDecoration(
                        labelText: 'Return item',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => _addItem(checklist),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (checklist.errorMessage != null)
                Text(
                  checklist.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (checklist.returnItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No return items yet.')),
                )
              else
                ...checklist.returnItems.map(
                  (item) => CheckboxListTile(
                    value: item.isPacked,
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.isPacked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    onChanged: (_) => checklist.togglePacked(item.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
