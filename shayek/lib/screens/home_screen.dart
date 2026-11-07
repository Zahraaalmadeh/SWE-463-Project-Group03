import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/trip.dart';
import '../providers/checklist_provider.dart';
import '../providers/trip_provider.dart';
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

/// Gradient placeholders cycled by trip index until real trip photos exist.
const _cardGradients = [
  [Color(0xFF93A49B), Color(0xFF456B61), Color(0xFF193A38)],
  [Color(0xFF6E9187), Color(0xFF385C50), Color(0xFF172F2D)],
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
      backgroundColor: const Color(0xFFF9FAF6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 32, 40, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandHeader(),
                  const SizedBox(height: 40),
                  const _HomeHeaderRow(),
                  const SizedBox(height: 48),
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Trips',
              style: TextStyle(
                color: Color(0xFF1A2925),
                fontFamily: 'Georgia',
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${trips.length} trip${trips.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 15, color: Color(0xFF607168)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 24.0;
            // 640 is roughly two card-widths' worth of room; below it a
            // single column reads better than two cramped columns.
            final isWide = constraints.maxWidth >= 640;
            final cardWidth = isWide
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final (index, trip) in trips.indexed)
                  SizedBox(
                    width: cardWidth,
                    child: HomeTripCard(
                      trip: _toHomeTrip(trip, index),
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

  /// Stores the tapped trip on ChecklistProvider, then navigates. Checklist
  /// reads the selection from the provider instead of a route argument, so
  /// every screen that needs "the selected trip" shares the same source.
  void _openChecklist(BuildContext context, Trip trip) {
    context.read<ChecklistProvider>().selectTrip(trip);
    Navigator.of(context).pushNamed(AppRoutes.checklist);
  }

  /// Adapts the persisted [Trip] into the card's display model. Packing
  /// progress needs the checklist data (out of scope for this feature), so it
  /// is shown as 0% until Checklist is wired up.
  HomeTrip _toHomeTrip(Trip trip, int index) {
    final date = trip.departureDate;
    return HomeTrip(
      name: trip.name,
      type: _typeLabel(trip.type),
      date: '${_monthNames[date.month - 1]} ${date.day}, ${date.year}',
      duration: '${trip.durationDays} day${trip.durationDays == 1 ? '' : 's'}',
      travelers: '${trip.travelerCount}',
      progress: 0,
      colors: _cardGradients[index % _cardGradients.length],
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
      child: CircularProgressIndicator(color: Color(0xFF436C5B)),
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
                    color: Color(0xFF436C5B),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF607168),
                    ),
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
            child: Center(child: _EmptyStateContent()),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFE7EEE8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.luggage_outlined,
            color: Color(0xFF436C5B),
            size: 34,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Your next adventure starts here',
          style: TextStyle(
            color: Color(0xFF1A2925),
            fontFamily: 'Georgia',
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create your first trip and Shayek will build a smart\npacking list tailored for it.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF607168)),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.createTrip),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF436C5B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Create Trip'),
        ),
      ],
    );
  }
}

class _HomeHeaderRow extends StatelessWidget {
  const _HomeHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // "Sara" is a placeholder: there's no auth/user profile yet, so this
        // isn't reading a real signed-in name.
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good afternoon, Sara',
                style: TextStyle(fontSize: 16, color: Color(0xFF607168)),
              ),
              SizedBox(height: 8),
              Text(
                'Ready for your next adventure?',
                style: TextStyle(
                  color: Color(0xFF1A2925),
                  fontFamily: 'Georgia',
                  fontSize: 34,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
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
        backgroundColor: const Color(0xFF436C5B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _BrandIcon(),
        SizedBox(width: 12),
        Text(
          'Shayek',
          style: TextStyle(
            color: Color(0xFF1A2925),
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF436C5B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.luggage_outlined, color: Colors.white, size: 22),
    );
  }
}
