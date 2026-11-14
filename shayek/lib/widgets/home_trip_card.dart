import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../theme/app_theme.dart';

/// Display model for [HomeTripCard], already formatted for the screen.
class HomeTrip {
  const HomeTrip({
    required this.name,
    required this.type,
    required this.typeLabel,
    required this.departureDay,
    required this.departureMonthYear,
    required this.duration,
    required this.travelers,
    required this.progress,
  });

  final String name;
  final TripType type;
  final String typeLabel;

  /// Day of month, zero-padded ("07"), shown large on the ticket stub.
  final String departureDay;

  /// e.g. "Nov 2026", shown under [departureDay].
  final String departureMonthYear;
  final String duration;
  final String travelers;
  final double progress;
}

/// A trip drawn as a boarding pass: details on the left, a perforated tear
/// line, and the departure date on a stub tinted by trip type.
class HomeTripCard extends StatelessWidget {
  const HomeTripCard({super.key, required this.trip, this.onTap});

  final HomeTrip trip;

  /// Null disables the tap (InkWell just shows no ripple); Home always
  /// passes a callback that opens that trip's Checklist.
  final VoidCallback? onTap;

  static const _stubWidth = 128.0;
  static const _notch = 22.0;

  @override
  Widget build(BuildContext context) {
    final colors = TripTypeColors.of(trip.type);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.line),
          ),
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 172),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _TicketBody(trip: trip, colors: colors),
                    ),
                    const _Perforation(),
                    _TicketStub(trip: trip, colors: colors, width: _stubWidth),
                  ],
                ),
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
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({required this.trip, required this.colors});

  final HomeTrip trip;
  final TripTypeColors colors;

  @override
  Widget build(BuildContext context) {
    final percent = (trip.progress * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 24, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trip.typeLabel, style: AppText.eyebrow(colors.onTint)),
          const SizedBox(height: 8),
          Text(
            trip.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.cardTitle.copyWith(fontSize: 26),
          ),
          const Spacer(),
          const SizedBox(height: 14),
          Text('${trip.duration} · ${trip.travelers}', style: AppText.muted),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: trip.progress,
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent% packed',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DEPARTS',
            style: TextStyle(
              color: colors.onTint,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trip.departureDay,
            style: AppText.display.copyWith(
              color: colors.onTint,
              fontSize: 46,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trip.departureMonthYear,
            style: TextStyle(
              color: colors.onTint,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
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
    const gap = 5.0;
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
