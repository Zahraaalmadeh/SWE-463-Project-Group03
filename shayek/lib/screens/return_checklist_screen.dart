import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

/// Phase 4 placeholder for the leaving-accommodation checklist and reminder.
class ReturnChecklistScreen extends StatelessWidget {
  const ReturnChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Return Checklist')),
      body: const EmptyState(
        icon: Icons.assignment_return_outlined,
        message: 'The return checklist and reminders are planned for Phase 4.',
      ),
    );
  }
}
