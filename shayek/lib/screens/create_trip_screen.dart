import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/trip.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  TripType _tripType = TripType.city;
  DateTime? _departureDate;
  int _travelerCount = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _departureDate ?? DateTime.now(),
    );
    if (date != null) {
      setState(() => _departureDate = date);
    }
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _departureDate == null) {
      if (_departureDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a departure date.')),
        );
      }
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.checklist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Temporary form for the Phase 3 navigation skeleton.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Trip name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a trip name.'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TripType>(
              initialValue: _tripType,
              decoration: const InputDecoration(labelText: 'Trip type'),
              items: TripType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.name)),
                  )
                  .toList(),
              onChanged: (type) => setState(() => _tripType = type!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (days)'),
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value ?? '') == null
                  ? 'Enter a valid duration.'
                  : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Departure date'),
              subtitle: Text(
                _departureDate == null
                    ? 'Select a date'
                    : MaterialLocalizations.of(context)
                          .formatMediumDate(_departureDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Travelers'),
                const Spacer(),
                IconButton(
                  onPressed: _travelerCount > 1
                      ? () => setState(() => _travelerCount--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$_travelerCount'),
                IconButton(
                  onPressed: () => setState(() => _travelerCount++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Generate checklist'),
            ),
          ],
        ),
      ),
    );
  }
}
