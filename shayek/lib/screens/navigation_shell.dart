import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../theme/app_theme.dart';
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
    final isHome = _selectedIndex == 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SharedSiteHeader(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index == _selectedIndex) return;
              Navigator.of(context).pushReplacementNamed(
                index == 0 ? AppRoutes.home : AppRoutes.templates,
              );
            },
            action: isHome
                ? HeaderActionButton(
                    label: 'New trip',
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.createTrip),
                  )
                : HeaderActionButton(
                    label: 'Create list',
                    onPressed: () => showCreateListDialog(context),
                  ),
          ),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
    );
  }
}
