import 'package:flutter/material.dart';

class HomeTrip {
  const HomeTrip({
    required this.name,
    required this.type,
    required this.date,
    required this.duration,
    required this.travelers,
    required this.progress,
    required this.colors,
  });

  final String name;
  final String type;
  final String date;
  final String duration;
  final String travelers;
  final double progress;
  final List<Color> colors;
}

/// Reusable trip card used only by the Home page.
class HomeTripCard extends StatelessWidget {
  const HomeTripCard({super.key, required this.trip});

  final HomeTrip trip;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shadowColor: const Color(0xFF436C5B).withValues(alpha: 0.18),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
      child: Column(
        children: [
          _TripImagePlaceholder(trip: trip),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 26, 32, 32),
            child: Column(
              children: [
                Row(
                  children: [
                    _TripDetail(
                      icon: Icons.calendar_today_outlined,
                      text: trip.date,
                    ),
                    const SizedBox(width: 28),
                    _TripDetail(
                      icon: Icons.access_time_outlined,
                      text: trip.duration,
                    ),
                    const SizedBox(width: 28),
                    _TripDetail(
                      icon: Icons.people_outline,
                      text: trip.travelers,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: trip.progress,
                          minHeight: 16,
                          backgroundColor: const Color(0xFFDCE9E1),
                          color: const Color(0xFF436C5B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                    Text(
                      '${(trip.progress * 100).round()}%',
                      style: const TextStyle(
                        color: Color(0xFF436C5B),
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripImagePlaceholder extends StatelessWidget {
  const _TripImagePlaceholder({required this.trip});

  final HomeTrip trip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: DecoratedBox(
        // Temporary local scenery until the team adds approved trip photos.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: trip.colors,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  trip.type,
                  style: const TextStyle(
                    color: Color(0xFF436C5B),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                trip.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Georgia',
                  fontSize: 46,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripDetail extends StatelessWidget {
  const _TripDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF607168), size: 26),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF607168), fontSize: 24),
        ),
      ],
    );
  }
}
