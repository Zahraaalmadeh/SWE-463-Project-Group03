import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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

/// Top bar shared by Home, Lists and the checklist: logo on the left, the two
/// main destinations as underlined text links.
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1160),
            child: Wrap(
              spacing: 40,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const ShayekLogo(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SiteNavLink(
                      label: 'Home',
                      selected: selectedIndex == 0,
                      onPressed: () => onDestinationSelected(0),
                    ),
                    const SizedBox(width: 12),
                    _SiteNavLink(
                      label: 'Lists',
                      selected: selectedIndex == 1,
                      onPressed: () => onDestinationSelected(1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Suitcase mark + wordmark.
class ShayekLogo extends StatelessWidget {
  const ShayekLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(size: Size.square(30), painter: _SuitcasePainter()),
        SizedBox(width: 10),
        Text('Shayek', style: AppText.brand),
      ],
    );
  }
}

class _SuitcasePainter extends CustomPainter {
  const _SuitcasePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 32;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(6 * s, 10 * s, 20 * s, 17 * s),
      Radius.circular(4 * s),
    );
    canvas.drawRRect(body, Paint()..color = AppColors.accent);

    final stroke = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * s
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawPath(
        Path()
          ..moveTo(12 * s, 10 * s)
          ..lineTo(12 * s, 7 * s)
          ..arcToPoint(Offset(14 * s, 5 * s), radius: Radius.circular(2 * s))
          ..lineTo(18 * s, 5 * s)
          ..arcToPoint(Offset(20 * s, 7 * s), radius: Radius.circular(2 * s))
          ..lineTo(20 * s, 10 * s),
        stroke,
      )
      ..drawLine(Offset(11 * s, 15 * s), Offset(11 * s, 22 * s), stroke)
      ..drawLine(Offset(21 * s, 15 * s), Offset(21 * s, 22 * s), stroke);
  }

  @override
  bool shouldRepaint(_SuitcasePainter oldDelegate) => false;
}

class _SiteNavLink extends StatelessWidget {
  const _SiteNavLink({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? AppColors.accent : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.ink : AppColors.muted,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiet footer on the same paper background, separated by a hairline.
class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  static const _links = [
    'Help center',
    'Contact us',
    'Feedback',
    'About Shayek',
    'Privacy',
    'Terms',
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1160),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 8,
              children: [
                const Text(
                  '© 2026 Shayek · Pack with confidence.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                Wrap(
                  spacing: 20,
                  runSpacing: 6,
                  children: [
                    for (final link in _links)
                      Text(
                        link,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
