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
                          label: 'Lists',
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

class SharedSiteHeader extends StatelessWidget {
  const SharedSiteHeader({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAF6),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final navigation = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SiteNavButton(
                    label: 'Home',
                    icon: Icons.home_outlined,
                    selected: selectedIndex == 0,
                    onPressed: () => onDestinationSelected(0),
                  ),
                  const SizedBox(width: 8),
                  _SiteNavButton(
                    label: 'Lists',
                    icon: Icons.view_list_outlined,
                    selected: selectedIndex == 1,
                    onPressed: () => onDestinationSelected(1),
                  ),
                ],
              );
              const brand = Text(
                'Shayek',
                style: TextStyle(
                  color: Color(0xFF1A2925),
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              );

              if (constraints.maxWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [brand, const SizedBox(height: 12), navigation],
                );
              }

              return Row(children: [brand, const Spacer(), navigation]);
            },
          ),
        ),
      ),
    );
  }
}

class _SiteNavButton extends StatelessWidget {
  const _SiteNavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF456F60),
        backgroundColor: selected
            ? const Color(0xFFDCECE2)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A2925),
        border: Border(top: BorderSide(color: Color(0xFF30463D))),
      ),
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = Wrap(
                spacing: 64,
                runSpacing: 28,
                children: const [
                  _FooterColumn(
                    title: 'Support',
                    links: ['Help center', 'Contact us', 'Feedback'],
                  ),
                  _FooterColumn(
                    title: 'Explore',
                    links: ['Your trips', 'Packing lists', 'Travel tips'],
                  ),
                  _FooterColumn(
                    title: 'Company',
                    links: ['About Shayek', 'Privacy', 'Terms'],
                  ),
                ],
              );

              final introduction = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Shayek',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 260,
                    child: Text(
                      'Pack with confidence. Travel with less to think about.',
                      style: TextStyle(color: Color(0xFFB7C8BE), height: 1.5),
                    ),
                  ),
                ],
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (constraints.maxWidth >= 760)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [introduction, const Spacer(), columns],
                    )
                  else ...[
                    introduction,
                    const SizedBox(height: 28),
                    columns,
                  ],
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFF30463D), height: 1),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Text(
                        '© 2026 Shayek',
                        style: TextStyle(color: Color(0xFFB7C8BE)),
                      ),
                      Text(
                        'Private by default · Built for better journeys',
                        style: TextStyle(color: Color(0xFFB7C8BE)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});

  final String title;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...links.map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Text(
                link,
                style: const TextStyle(color: Color(0xFFB7C8BE), fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
