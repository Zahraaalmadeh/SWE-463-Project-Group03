import 'package:flutter/material.dart';

import '../app_routes.dart';

/// Bottom navigation shared by the Home and Templates tabs throughout Shayek.
class SharedBottomNavigationBar extends StatelessWidget {
  const SharedBottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _navigationColor = Color(0xFF607168);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
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
    );
  }
}
