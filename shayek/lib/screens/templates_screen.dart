import 'package:flutter/material.dart';

import '../app_routes.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Create Trip'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.createTrip),
          ),
        ],
      ),
    );
  }
}
