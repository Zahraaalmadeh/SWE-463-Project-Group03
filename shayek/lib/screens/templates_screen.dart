import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/empty_state.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: EmptyState(
        icon: Icons.bookmarks_outlined,
        message: 'Saved packing templates will appear here.',
        action: OutlinedButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.createTrip),
          icon: const Icon(Icons.add),
          label: const Text('Create trip'),
        ),
      ),
    );
  }
}
