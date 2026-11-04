import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

/// Phase 4 placeholder for per-traveler and shared-item management.
class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Members')),
      body: const EmptyState(
        icon: Icons.family_restroom_outlined,
        message: 'Family member lists are planned for Phase 4.',
      ),
    );
  }
}
