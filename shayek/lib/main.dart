import 'package:flutter/material.dart';

void main() {
  runApp(const ShayekApp());
}

const green = Color(0xFF185C45);
const pageBackground = Color(0xFFF8F8F4);

class ShayekApp extends StatelessWidget {
  const ShayekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shayek',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
      ),
      home: const ShayekHome(),
    );
  }
}

class ShayekHome extends StatefulWidget {
  const ShayekHome({super.key});

  @override
  State<ShayekHome> createState() => _ShayekHomeState();
}

class _ShayekHomeState extends State<ShayekHome> {
  int selectedTab = 0;

  void openPlaceholder(String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PlaceholderScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: selectedTab == 0
            ? HomeContent(
                onNewTrip: () => openPlaceholder('New Trip'),
                onTripTap: (tripName) => openPlaceholder('$tripName Checklist'),
              )
            : const TemplatesContent(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Templates',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.onNewTrip,
    required this.onTripTap,
  });

  final VoidCallback onNewTrip;
  final ValueChanged<String> onTripTap;

  static const trips = [
    Trip(
      name: 'Amalfi Coast',
      type: 'Beach',
      date: 'Nov 6, 2026',
      duration: '7 days',
      travelers: '2',
      progress: 0.64,
    ),
    Trip(
      name: 'Camping Weekend',
      type: 'Camping',
      date: 'Dec 12, 2026',
      duration: '3 days',
      travelers: '2',
      progress: 0.28,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.luggage_outlined,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Shayek',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          'Good afternoon, Sara',
          style: TextStyle(fontSize: 17, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ready for your next adventure?',
          style: TextStyle(fontSize: 38, height: 1.08, fontFamily: 'Georgia'),
        ),
        const SizedBox(height: 25),
        SizedBox(
          height: 58,
          child: FilledButton.icon(
            onPressed: onNewTrip,
            icon: const Icon(Icons.add, size: 25),
            label: const Text('New Trip', style: TextStyle(fontSize: 18)),
            style: FilledButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Trips',
              style: TextStyle(fontSize: 27, fontFamily: 'Georgia'),
            ),
            Text(
              '${trips.length} trips',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final trip in trips)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: TripCard(trip: trip, onTap: () => onTripTap(trip.name)),
          ),
      ],
    );
  }
}

class Trip {
  const Trip({
    required this.name,
    required this.type,
    required this.date,
    required this.duration,
    required this.travelers,
    required this.progress,
  });

  final String name;
  final String type;
  final String date;
  final String duration;
  final String travelers;
  final double progress;
}

class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip, required this.onTap});

  final Trip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (trip.progress * 100).round();

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Replace this gradient with the approved trip photo asset later.
            SizedBox(
              height: 190,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB9D2C7),
                          Color(0xFF648B78),
                          Color(0xFF254C40),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        trip.type,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 16,
                    child: Text(
                      trip.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontFamily: 'Georgia',
                        shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 7),
                      Text(trip.date),
                      const SizedBox(width: 14),
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 6),
                      Text(trip.duration),
                      const SizedBox(width: 14),
                      const Icon(Icons.people_outline, size: 19),
                      const SizedBox(width: 5),
                      Text(trip.travelers),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: trip.progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE5EAE5),
                          color: green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$percent%'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TemplatesContent extends StatelessWidget {
  const TemplatesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_outlined, size: 54, color: green),
            SizedBox(height: 12),
            Text(
              'Templates',
              style: TextStyle(fontSize: 28, fontFamily: 'Georgia'),
            ),
            SizedBox(height: 8),
            Text(
              'Saved packing templates will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title screen placeholder')),
    );
  }
}
