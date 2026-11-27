import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/traveler.dart';
import '../models/trip.dart';
import '../providers/checklist_provider.dart';
import '../providers/traveler_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/page_scaffold.dart';

/// The people travelling on a trip. Items can then be assigned to a member
/// from the checklist's item editor; each member shows how many they have.
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
    final messenger = ScaffoldMessenger.of(context);
    final travelers = context.read<TravelerProvider>();
    try {
      await travelers.addTraveler(name);
      if (!mounted) return;
      if (travelers.errorMessage == null) {
        _nameController.clear();
        messenger.showSnackBar(
          const SnackBar(content: Text('Family member added')),
        );
      }
    } on ArgumentError catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a family member name')),
      );
    }
  }

  Future<void> _removeMember(Traveler traveler) async {
    final travelers = context.read<TravelerProvider>();
    final checklist = context.read<ChecklistProvider>();
    await travelers.removeTraveler(traveler.id);
    if (!mounted || travelers.errorMessage != null) return;
    // Items assigned to this person go back to "Everyone".
    checklist.unassignTraveler(traveler.id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${traveler.name} removed')));
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    if (trip == null) {
      return const PageScaffold(
        backLabel: 'Back',
        title: 'Family members',
        child: PageMessage(
          title: 'No trip selected',
          message: 'Open Family members from one of your trips.',
        ),
      );
    }

    return PageScaffold(
      backLabel: 'Back',
      title: 'Family members',
      subtitle:
          '${trip.name} · assign items to each person from the '
          'checklist’s item editor.',
      child: Consumer2<TravelerProvider, ChecklistProvider>(
        builder: (context, provider, checklist, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PillInputRow(
                controller: _nameController,
                hint: 'Family member name',
                buttonLabel: 'Add',
                onSubmit: _addMember,
              ),
              const SizedBox(height: 14),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: InlineError(message: provider.errorMessage!),
                ),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.travelers.isEmpty)
                const PageMessage(
                  title: 'No family members yet',
                  message:
                      'Add the people travelling on this trip, then assign '
                      'items to them from the checklist.',
                )
              else
                SheetCard(
                  children: [
                    for (final traveler in provider.travelers)
                      _MemberRow(
                        traveler: traveler,
                        itemCount: checklist.assignedCountFor(
                          trip.id,
                          traveler.id,
                        ),
                        onRemove: () => _removeMember(traveler),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context)
                          .pushNamed(AppRoutes.checklist, arguments: trip),
                  icon: const Icon(Icons.checklist, size: 18),
                  label: const Text('Open packing checklist'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.traveler,
    required this.itemCount,
    required this.onRemove,
  });

  final Traveler traveler;
  final int itemCount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final initial = traveler.name.isEmpty
        ? '?'
        : traveler.name.characters.first.toUpperCase();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.sand,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  traveler.name,
                  style: const TextStyle(color: AppColors.ink, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  itemCount == 0
                      ? 'No items assigned'
                      : '$itemCount item${itemCount == 1 ? '' : 's'} assigned',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove ${traveler.name}',
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.muted,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
