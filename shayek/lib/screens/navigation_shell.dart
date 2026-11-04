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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 148,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _navigationColor),
            borderRadius: BorderRadius.circular(44),
          ),
          child: NavigationBarTheme(
            data: const NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: Colors.transparent,
              iconTheme: WidgetStatePropertyAll(
                IconThemeData(color: _navigationColor, size: 38),
              ),
              labelTextStyle: WidgetStatePropertyAll(
                TextStyle(color: _navigationColor, fontSize: 24),
              ),
            ),
            child: NavigationBar(
              height: 148,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                if (index == _selectedIndex) {
                  return;
                }
                if (index == 0) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.home);
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
    );
  }
}
