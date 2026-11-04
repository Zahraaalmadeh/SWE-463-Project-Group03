import 'package:flutter/material.dart';

import '../app_routes.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Packing Checklist')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Templates'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.templates),
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
