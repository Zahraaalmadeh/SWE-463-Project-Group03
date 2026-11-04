import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/empty_state.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing Checklist'),
        actions: [
          IconButton(
            tooltip: 'Save as template',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.templates),
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
      body: EmptyState(
        icon: Icons.checklist_outlined,
        message: 'Generated packing items will appear here.',
        action: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.family),
              child: const Text('Family members'),
            ),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.returnChecklist),
              child: const Text('Return checklist'),
            ),
          ],
        ),
      ),
    );
  }
}
