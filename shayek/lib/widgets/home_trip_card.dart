import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../theme/app_theme.dart';
import 'dashed_border.dart';

/// Display model for [HomeTripCard], already formatted for the screen.
class HomeTrip {
  const HomeTrip({
    required this.name,
    required this.type,
    required this.typeLabel,
    required this.departureDay,
    required this.departureMonthYear,
    required this.details,
  });

  final String name;
  final TripType type;

  /// Upper-case label above the name, e.g. "FAMILY TRIP".
  final String typeLabel;

  /// Day of month, zero-padded ("02"), shown large on the ticket stub.
  final String departureDay;

  /// e.g. "Nov 2026", shown under [departureDay].
  final String departureMonthYear;

  /// e.g. "5 days · 4 travelers".
  final String details;
}

/// Height every Home card shares, so tickets and the "Plan another trip" card
/// line up in the grid.
const double homeCardHeight = 176;

/// A trip drawn as a boarding pass: details on the left, a dashed tear line,
/// and the departure date on a stub tinted by trip type. Lifts slightly on
/// hover.
class HomeTripCard extends StatefulWidget {
  const HomeTripCard({super.key, required this.trip, this.onTap});

  final HomeTrip trip;

  /// Null disables the tap (InkWell just shows no ripple); Home always
  /// passes a callback that opens that trip's Checklist.
  final VoidCallback? onTap;

  @override
  State<HomeTripCard> createState() => _HomeTripCardState();
}

class _HomeTripCardState extends State<HomeTripCard> {
  static const _stubWidth = 140.0;
  static const _notch = 22.0;
  static const _radius = 18.0;

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final colors = TripTypeColors.of(trip.type);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            if (_hovered)
              const BoxShadow(
                color: Color(0x141E2430),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: AppColors.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_radius),
                side: const BorderSide(color: AppColors.line),
              ),
              child: InkWell(
                onTap: widget.onTap,
                hoverColor: Colors.transparent,
                child: SizedBox(
                  height: homeCardHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _TicketBody(trip: trip, colors: colors),
                      ),
                      const _Perforation(),
                      _TicketStub(
                        trip: trip,
                        colors: colors,
                        width: _stubWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Half-circle notches where the ticket would tear, painted in the
            // page colour so they read as cut-outs.
            for (final top in [true, false])
              Positioned(
                right: _stubWidth - _notch / 2,
                top: top ? -_notch / 2 : null,
                bottom: top ? null : -_notch / 2,
                child: const IgnorePointer(child: _Notch(size: _notch)),
              ),
          ],
        ),
      ),
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({required this.trip, required this.colors});

  final HomeTrip trip;
  final TripTypeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trip.typeLabel, style: AppText.eyebrow(colors.onTint)),
          const SizedBox(height: 10),
          Text(
            trip.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.cardTitle.copyWith(fontSize: 28, height: 1.15),
          ),
          const Spacer(),
          Text(
            trip.details,
            style: const TextStyle(color: AppColors.muted, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _TicketStub extends StatelessWidget {
  const _TicketStub({
    required this.trip,
    required this.colors,
    required this.width,
  });

  final HomeTrip trip;
  final TripTypeColors colors;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: colors.tint,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DEPARTS',
            style: TextStyle(
              color: colors.onTint,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            trip.departureDay,
            style: TextStyle(
              color: colors.onTint,
              fontFamily: AppText.serif,
              fontSize: 48,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            trip.departureMonthYear,
            style: TextStyle(
              color: colors.onTint,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The 2px dashed tear line between the ticket body and its stub.
class _Perforation extends StatelessWidget {
  const _Perforation();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: CustomPaint(size: Size(2, 0), painter: _DashPainter()),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 2;
    const dash = 6.0;
    const gap = 6.0;
    for (var y = 0.0; y < size.height; y += dash + gap) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + dash).clamp(0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}

class _Notch extends StatelessWidget {
  const _Notch({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.line),
      ),
    );
  }
}

/// Dashed "Plan another trip" card that sits after the trips in the grid.
class PlanAnotherTripCard extends StatelessWidget {
  const PlanAnotherTripCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: const Color(0xFFD5CCBC),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: homeCardHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Plan another trip',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
