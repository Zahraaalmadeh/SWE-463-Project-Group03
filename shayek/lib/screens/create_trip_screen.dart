import 'package:flutter/material.dart';

import '../app_routes.dart';

/// Phase 3 route placeholder; trip fields will be implemented later.
class CreateTripScreen extends StatelessWidget {
  const CreateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Trip')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Packing Checklist'),
            onTap: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.checklist),
          ),
        ],
      ),
    );
  }
}
