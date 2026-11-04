import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/home_trip_card.dart';

/// Home UI for the Phase 3 design. The trip data is temporary display data.
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(42, 44, 42, 40),
          children: [
            const _BrandHeader(),
            const SizedBox(height: 66),
            const Text(
              'Good afternoon, Sara',
              style: TextStyle(fontSize: 28, color: Color(0xFF607168)),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ready for your next\nadventure?',
              style: TextStyle(
                color: Color(0xFF1A2925),
                fontFamily: 'Georgia',
                fontSize: 62,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 54),
            SizedBox(
              height: 112,
              child: FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.createTrip),
                icon: const Icon(Icons.add, size: 40),
                label: const Text('New Trip'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF436C5B),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 78),
            const Row(
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Upcoming Trips',
                      style: TextStyle(
                        color: Color(0xFF1A2925),
                        fontFamily: 'Georgia',
                        fontSize: 48,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  '2 trips',
                  style: TextStyle(fontSize: 28, color: Color(0xFF607168)),
                ),
              ],
            ),
            const SizedBox(height: 34),
            for (final trip in _trips) ...[
              HomeTripCard(trip: trip),
              const SizedBox(height: 40),
            ],
          ],
        ),
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
        SizedBox(width: 18),
        Text(
          'Shayek',
          style: TextStyle(
            color: Color(0xFF1A2925),
            fontFamily: 'Georgia',
            fontSize: 42,
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
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF436C5B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.luggage_outlined, color: Colors.white, size: 42),
    );
  }
}
