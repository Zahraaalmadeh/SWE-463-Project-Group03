import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/empty_state.dart';

/// Temporary Phase 3 Home placeholder; the final Home design is not included.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: EmptyState(
        icon: Icons.luggage_outlined,
        message: 'Your trips will appear here.',
        action: FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.createTrip),
          icon: const Icon(Icons.add),
          label: const Text('Create trip'),
        ),
      ),
    );
  }
}
