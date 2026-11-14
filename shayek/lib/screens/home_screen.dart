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

/// Home tab: the user's trips as boarding-pass cards.
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
    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: AppLayout.pageWidth),
              padding: EdgeInsets.fromLTRB(
                AppLayout.gutter(context),
                56,
                AppLayout.gutter(context),
                80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HighlightedHeading(
                    before: 'Your ',
                    highlighted: 'trips',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pick a trip to keep packing, or start a new one.',
                    style: AppText.lead,
                  ),
                  const SizedBox(height: 40),
                  // Consumer rebuilds only this section when TripProvider calls
                  // notifyListeners(), so the list stays in sync automatically
                  // whenever trips are loaded, added, or removed.
                  Consumer<TripProvider>(
                    builder: (context, tripProvider, _) {
                      if (tripProvider.isLoading) {
                        return const _LoadingState();
                      }
                      if (tripProvider.errorMessage != null) {
                        return _ErrorState(message: tripProvider.errorMessage!);
                      }
                      if (tripProvider.trips.isEmpty) {
                        return const _EmptyState();
                      }
                      return _TripGrid(trips: tripProvider.trips);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripGrid extends StatelessWidget {
  const _TripGrid({required this.trips});

  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 28.0;
        // Each ticket needs ~500px to keep the name readable beside the
        // date stub; below two of those, use a single column.
        final isWide = constraints.maxWidth >= 500 * 2 + spacing;
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
            SizedBox(
              width: cardWidth,
              child: PlanAnotherTripCard(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.createTrip),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Opens the tapped trip's checklist. ChecklistScreen takes the trip as its
  /// route argument and selects it on ChecklistProvider itself, the same way
  /// Create Trip's "Generate Packing List" opens it.
  void _openChecklist(BuildContext context, Trip trip) {
    Navigator.of(context).pushNamed(AppRoutes.checklist, arguments: trip);
  }

  /// Adapts the persisted [Trip] into the card's display model.
  HomeTrip _toHomeTrip(Trip trip) {
    final date = trip.departureDate;
    final days = trip.durationDays;
    final travelers = trip.travelerCount;
    return HomeTrip(
      name: trip.name,
      type: trip.type,
      typeLabel: '${trip.type.name.toUpperCase()} TRIP',
      departureDay: date.day.toString().padLeft(2, '0'),
      departureMonthYear: '${_monthNames[date.month - 1]} ${date.year}',
      details:
          '$days day${days == 1 ? '' : 's'} · '
          '$travelers traveler${travelers == 1 ? '' : 's'}',
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: homeCardHeight,
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 44),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: AppText.lead),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.sand,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.luggage_outlined,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your next adventure starts here',
              textAlign: TextAlign.center,
              style: AppText.cardTitle.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create your first trip and Shayek will build a smart\npacking list tailored for it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 16,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 26),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.createTrip),
              child: const Text('Create Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
