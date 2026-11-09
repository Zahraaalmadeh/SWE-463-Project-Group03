import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/shared_bottom_navigation_bar.dart';
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
      bottomNavigationBar: SharedBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == _selectedIndex) return;
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.templates);
          }
        },
      ),
    );
  }
}
