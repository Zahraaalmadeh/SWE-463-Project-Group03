import 'package:flutter/material.dart';

/// Bottom navigation shared by the Home and Templates tabs throughout Shayek.
///
/// Sized and centered for desktop: a compact floating pill instead of a
/// full-width, mobile-scaled bar, matching the approved Home/Templates design.
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        // Row + mainAxisAlignment.center (not Center) on purpose: Center
        // expands to fill whatever height Scaffold hands this slot, which
        // starved the body of space. Row only takes the height its child
        // needs and just centers it horizontally.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
