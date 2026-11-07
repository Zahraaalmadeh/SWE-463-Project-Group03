import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checklist_provider.dart';

/// Placeholder owned by the Checklist feature team. Reads the trip Home
/// selected via ChecklistProvider so it opens the correct trip; checklist
/// generation and management are not implemented yet.
class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<ChecklistProvider>().selectedTrip;
    return Scaffold(
      appBar: AppBar(title: Text(trip?.name ?? 'Packing Checklist')),
      body: trip == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Trip ID: ${trip.id}'),
            ),
    );
  }
}
