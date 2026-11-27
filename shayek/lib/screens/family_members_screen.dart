import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/traveler_provider.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key, this.trip});

  final Trip? trip;

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trip = widget.trip;
      if (trip != null && mounted) {
        context.read<TravelerProvider>().loadTravelers(trip.id);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    final name = _nameController.text;
    try {
      await context.read<TravelerProvider>().addTraveler(name);
      if (!mounted) return;
      _nameController.clear();
      if (context.read<TravelerProvider>().errorMessage == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Family member added')));
      }
    } on ArgumentError catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a family member name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return Scaffold(
      appBar: AppBar(title: const Text('Family Members')),
      body: Consumer<TravelerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trip != null)
                  Text(
                    trip.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addMember(),
                        decoration: const InputDecoration(
                          labelText: 'Family member name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _addMember,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (provider.errorMessage != null)
                  Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (provider.travelers.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No family members have been added.'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: provider.travelers.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final traveler = provider.travelers[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_outline),
                          ),
                          title: Text(traveler.name),
                          trailing: IconButton(
                            tooltip: 'Remove ${traveler.name}',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                provider.removeTraveler(traveler.id),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
