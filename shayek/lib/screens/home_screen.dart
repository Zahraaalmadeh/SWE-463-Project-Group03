import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/home_trip_card.dart';

/// Desktop-sized Home UI for the Phase 3 design. The trip data is temporary display data.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _trips = [
    HomeTrip(
      name: 'Amalfi Coast',
      type: 'Beach',
      date: 'Nov 6, 2026',
      duration: '7 days',
      travelers: '2',
      progress: 0.64,
      colors: [Color(0xFF93A49B), Color(0xFF456B61), Color(0xFF193A38)],
    ),
    HomeTrip(
      name: 'Banff Lakes',
      type: 'Camping',
      date: 'Dec 12, 2026',
      duration: '3 days',
      travelers: '2',
      progress: 0.28,
      colors: [Color(0xFF6E9187), Color(0xFF385C50), Color(0xFF172F2D)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(40, 32, 40, 40),
              children: [
                const _BrandHeader(),
                const SizedBox(height: 40),
                const _HomeHeaderRow(),
                const SizedBox(height: 48),
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
                      '${_trips.length} trips',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF607168),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 24.0;
                    final isWide = constraints.maxWidth >= 640;
                    final cardWidth = isWide
                        ? (constraints.maxWidth - spacing) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final trip in _trips)
                          SizedBox(
                            width: cardWidth,
                            child: HomeTripCard(trip: trip),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
