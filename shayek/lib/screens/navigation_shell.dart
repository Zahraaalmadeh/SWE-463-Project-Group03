import 'package:flutter/material.dart';

import '../app_routes.dart';
import 'home_screen.dart';
import 'templates_screen.dart';

/// Hosts the two main tabs so they remain consistent across the app.
class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  static const _navigationColor = Color(0xFF607168);

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    const screens = [HomeScreen(), TemplatesScreen()];

    return Scaffold(
      body: screens[_selectedIndex],
      // Shared bottom navigation matching the approved Home/Templates design.
      // Sized and centered for desktop: a compact floating pill instead of
      // a full-width, mobile-scaled bar.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          // Row + mainAxisAlignment.center (not Center) on purpose: Center
          // expands to fill whatever height Scaffold hands this slot, which
          // starved the body of space. Row only takes the height its child
          // needs and just centers it horizontally.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  height: 68,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: _navigationColor.withValues(alpha: 0.16),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: NavigationBarTheme(
                    data: const NavigationBarThemeData(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      indicatorColor: Colors.transparent,
                      iconTheme: WidgetStatePropertyAll(
                        IconThemeData(color: _navigationColor, size: 22),
                      ),
                      labelTextStyle: WidgetStatePropertyAll(
                        TextStyle(color: _navigationColor, fontSize: 12),
                      ),
                    ),
                    child: NavigationBar(
                      height: 68,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        if (index == _selectedIndex) {
                          return;
                        }
                        if (index == 0) {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.home);
                        } else {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.templates);
                        }
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_outlined),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.widgets_outlined),
                          selectedIcon: Icon(Icons.widgets_outlined),
                          label: 'Templates',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
