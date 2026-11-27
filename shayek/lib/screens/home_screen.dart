import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/trip.dart';
import '../providers/checklist_provider.dart';
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
        _loadHomeData();
      }
    });
  }

  /// Loads trips, then each trip's items so the cards can show progress.
  /// [refresh] reloads trips even if they loaded before (used by "Try again").
  Future<void> _loadHomeData({bool refresh = false}) async {
    final tripProvider = context.read<TripProvider>();
    await tripProvider.loadTrips(refresh: refresh);
    if (!mounted) return;
    final checklistProvider = context.read<ChecklistProvider>();
    for (final trip in tripProvider.trips) {
      await checklistProvider.loadItems(trip.id);
    }
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
                        return _ErrorState(
                          message: tripProvider.errorMessage!,
                          onRetry: () => _loadHomeData(refresh: true),
                        );
                      }
                      if (tripProvider.trips.isEmpty) {
                        return const _EmptyState();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReminderBanners(trips: tripProvider.trips),
                          _TripGrid(trips: tripProvider.trips),
                        ],
                      );
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
    return Consumer<ChecklistProvider>(
      builder: (context, checklistProvider, _) => LayoutBuilder(
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
                    trip: _toHomeTrip(trip, checklistProvider),
                    onTap: () => _openChecklist(context, trip),
                    onFamilyMembers: () =>
                        Navigator.of(context)
                            .pushNamed(AppRoutes.family, arguments: trip),
                    onReturnChecklist: () => Navigator.of(context)
                        .pushNamed(AppRoutes.returnChecklist, arguments: trip),
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
      ),
    );
  }

  /// Opens the tapped trip's checklist. ChecklistScreen takes the trip as its
  /// route argument and selects it on ChecklistProvider itself, the same way
  /// Create Trip's "Generate Packing List" opens it.
  void _openChecklist(BuildContext context, Trip trip) {
    Navigator.of(context).pushNamed(AppRoutes.checklist, arguments: trip);
  }

  /// Adapts the persisted [Trip] and its shared checklist state into the
  /// card's display model.
  HomeTrip _toHomeTrip(Trip trip, ChecklistProvider checklist) {
    final date = trip.departureDate;
    final days = trip.durationDays;
    final travelers = trip.travelerCount;
    final month = _monthNames[date.month - 1];
    final reminder = trip.reminderTime;
    return HomeTrip(
      name: trip.name,
      type: trip.type,
      typeLabel: '${trip.type.name.toUpperCase()} TRIP',
      departureDay: date.day.toString().padLeft(2, '0'),
      departureMonthYear: '$month ${date.year}',
      departureLabel: '${date.day} $month ${date.year}',
      details:
          '$days day${days == 1 ? '' : 's'} · '
          '$travelers traveler${travelers == 1 ? '' : 's'}',
      packedCount: checklist.packedCountFor(trip.id),
      totalCount: checklist.totalCountFor(trip.id),
      progressUnavailable: checklist.failedToLoad(trip.id),
      reminderLabel: trip.reminderEnabled && reminder != null
          ? 'Reminder ${_formatTime(reminder)}'
          : null,
    );
  }
}

/// "9:00 PM" style time.
String _formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
}

/// In-app departure reminders: one banner per trip that has its reminder on
/// and leaves today or tomorrow. Shown at the top of Home, so the reminder
/// set on the Return Checklist screen is visible without notifications.
class _ReminderBanners extends StatelessWidget {
  const _ReminderBanners({required this.trips});

  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = <(Trip, int)>[];
    for (final trip in trips) {
      if (!trip.reminderEnabled || trip.reminderTime == null) continue;
      final departure = trip.departureDate;
      final daysAway = DateTime(
        departure.year,
        departure.month,
        departure.day,
      ).difference(today).inDays;
      if (daysAway == 0 || daysAway == 1) due.add((trip, daysAway));
    }
    if (due.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (trip, daysAway) in due)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReminderBanner(
                trip: trip,
                when: daysAway == 0 ? 'today' : 'tomorrow',
              ),
            ),
        ],
      ),
    );
  }
}

class _ReminderBanner extends StatelessWidget {
  const _ReminderBanner({required this.trip, required this.when});

  final Trip trip;
  final String when;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2D98A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: Color(0xFF7A5A00),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${trip.name} leaves $when. ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'Departure reminder set for '
                        '${_formatTime(trip.reminderTime!)}.',
                  ),
                ],
              ),
              style: const TextStyle(color: Color(0xFF4D3900), fontSize: 15),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .pushNamed(AppRoutes.checklist, arguments: trip),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4D3900),
            ),
            child: const Text('Open checklist'),
          ),
        ],
      ),
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
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
            ),
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
