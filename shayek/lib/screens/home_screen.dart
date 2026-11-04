import 'package:flutter/material.dart';

import '../app_routes.dart';

/// Temporary Phase 3 Home placeholder; the final Home design is not included.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Create Trip'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.createTrip),
          ),
          ListTile(
            title: const Text('Packing Checklist'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.checklist),
          ),
          ListTile(
            title: const Text('Family Members'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.family),
          ),
          ListTile(
            title: const Text('Return Checklist'),
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.returnChecklist),
          ),
        ],
      ),
    );
  }
}
