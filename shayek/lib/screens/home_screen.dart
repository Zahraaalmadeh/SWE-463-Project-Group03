import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/home_trip_card.dart';

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Desktop-sized Home UI for the Phase 3 design.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Home triggers the initial load; TripProvider owns the database call so
    // this screen never touches SQLite itself. The call is deferred until
    // after the first frame because loadTrips() calls notifyListeners()
    // immediately (to show the loading state), and doing that synchronously
    // inside initState would mark the provider dirty while the widget tree
    // is still being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TripProvider>().loadTrips();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1160),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HomeHeaderRow(),
                  const SizedBox(height: 40),
                  // Consumer rebuilds only this section when TripProvider calls
                  // notifyListeners(), so the list stays in sync automatically
                  // whenever trips are loaded, added, or removed.
                  Expanded(
                    child: Consumer<TripProvider>(
                      builder: (context, tripProvider, _) {
                        if (tripProvider.isLoading) {
                          return const _LoadingState();
                        }
                        if (tripProvider.errorMessage != null) {
                          return _ErrorState(
                            message: tripProvider.errorMessage!,
                          );
                        }
                        if (tripProvider.trips.isEmpty) {
                          return const _EmptyState();
                        }
                        return _TripList(trips: tripProvider.trips);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  const _TripList({required this.trips});

  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Room for the ticket notches, which sit just outside each card.
      padding: const EdgeInsets.only(top: 4, bottom: 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text('Upcoming Trips', style: AppText.title),
            const SizedBox(width: 12),
            Text(
              '${trips.length} trip${trips.length == 1 ? '' : 's'}',
              style: AppText.muted.copyWith(fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 28.0;
            // Two tickets side by side need ~1000px; below that one column
            // keeps the trip name readable next to the date stub.
            final isWide = constraints.maxWidth >= 1000;
            final cardWidth = isWide
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final trip in trips)
                  SizedBox(
                    width: cardWidth,
                    child: HomeTripCard(
                      trip: _toHomeTrip(trip),
                      onTap: () => _openChecklist(context, trip),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Opens the tapped trip's checklist. ChecklistScreen takes the trip as its
  /// route argument and selects it on ChecklistProvider itself, the same way
  /// Create Trip's "Generate Packing List" opens it.
  void _openChecklist(BuildContext context, Trip trip) {
    Navigator.of(context).pushNamed(AppRoutes.checklist, arguments: trip);
  }

  /// Adapts the persisted [Trip] into the card's display model. Packing
  /// progress needs the checklist data (out of scope for this feature), so it
  /// is shown as 0% until Checklist is wired up.
  HomeTrip _toHomeTrip(Trip trip) {
    final date = trip.departureDate;
    final travelers = trip.travelerCount;
    return HomeTrip(
      name: trip.name,
      type: trip.type,
      typeLabel: _typeLabel(trip.type),
      departureDay: date.day.toString().padLeft(2, '0'),
      departureMonthYear: '${_monthNames[date.month - 1]} ${date.year}',
      duration: '${trip.durationDays} day${trip.durationDays == 1 ? '' : 's'}',
      travelers: '$travelers traveler${travelers == 1 ? '' : 's'}',
      progress: 0,
    );
  }

  String _typeLabel(TripType type) {
    final name = type.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    // Same scroll-when-short, center-when-roomy pattern as _EmptyState, so
    // this content never overflows on a small window either.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 44,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppText.lead,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder + a min-height ConstrainedBox lets this content center
    // itself when there's room, and scroll instead of overflowing when the
    // window is too short to fit it (e.g. a small macOS window).
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const Center(child: _EmptyStateContent()),
          ),
        );
      },
    );
  }
}

class _EmptyStateContent extends StatelessWidget {
  const _EmptyStateContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.fieldBorder, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.luggage_outlined,
              color: AppColors.accent,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your next adventure starts here',
            textAlign: TextAlign.center,
            style: AppText.title,
          ),
          const SizedBox(height: 10),
          const Text(
            'Create your first trip and Shayek will build a smart\npacking list tailored for it.',
            textAlign: TextAlign.center,
            style: AppText.lead,
          ),
          const SizedBox(height: 26),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.createTrip),
            child: const Text('Create Trip'),
          ),
        ],
      ),
    );
  }
}

class _HomeHeaderRow extends StatelessWidget {
  const _HomeHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 24,
      runSpacing: 20,
      children: [
        // "Sara" is a placeholder: there's no auth/user profile yet, so this
        // isn't reading a real signed-in name.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Good afternoon, Sara', style: AppText.lead),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Ready for your next '),
                    TextSpan(
                      text: 'adventure',
                      // Highlighter stroke behind the key word.
                      style: TextStyle(
                        background: Paint()
                          ..color = AppColors.highlight.withValues(alpha: 0.75),
                      ),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
                style: AppText.display,
              ),
            ],
          ),
        ),
        const _NewTripButton(),
      ],
    );
  }
}

class _NewTripButton extends StatelessWidget {
  const _NewTripButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createTrip),
      icon: const Icon(Icons.add, size: 20),
      label: const Text('New Trip'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
