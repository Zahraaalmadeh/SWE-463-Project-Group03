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
    required this.departureLabel,
    required this.details,
    required this.packedCount,
    required this.totalCount,
    this.progressUnavailable = false,
    this.reminderLabel,
  });

  final String name;
  final TripType type;

  /// Upper-case label above the name, e.g. "FAMILY TRIP".
  final String typeLabel;

  /// Day of month, zero-padded ("02"), shown large on the ticket stub.
  final String departureDay;

  /// e.g. "Nov 2026", shown under [departureDay].
  final String departureMonthYear;

  /// e.g. "20 Nov 2026", read out by screen readers.
  final String departureLabel;

  /// e.g. "5 days · 4 travelers".
  final String details;

  /// Packed and total packing items (return items excluded).
  final int packedCount;
  final int totalCount;

  /// True when this trip's items could not be loaded, so the counts above
  /// are unknown rather than zero.
  final bool progressUnavailable;

  /// e.g. "Reminder 9:00 PM" when a departure reminder is on, else null.
  final String? reminderLabel;

  double get progress => totalCount == 0 ? 0 : packedCount / totalCount;
  int get percent => (progress * 100).round();

  /// One sentence describing the card for screen readers.
  String get semanticsLabel {
    final status = progressUnavailable
        ? 'packing progress unavailable'
        : totalCount == 0
        ? 'no items yet'
        : '$packedCount of $totalCount items packed';
    final reminder = reminderLabel == null ? '' : ', ${reminderLabel!}';
    return '$name, ${type.name} trip, departs $departureLabel, '
        '$details, $status$reminder';
  }
}

/// Height every Home card shares, so tickets and the "Plan another trip" card
/// line up in the grid.
const double homeCardHeight = 214;

/// A trip drawn as a boarding pass: details on the left, a dashed tear line,
/// and the departure date on a stub tinted by trip type. Lifts slightly on
/// hover. Tapping the card opens the checklist; the links along the bottom
/// open the trip's Family members and Return checklist screens.
class HomeTripCard extends StatefulWidget {
  const HomeTripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onFamilyMembers,
    this.onReturnChecklist,
  });

  final HomeTrip trip;

  /// Null disables the tap (InkWell just shows no ripple); Home always
  /// passes a callback that opens that trip's Checklist.
  final VoidCallback? onTap;
  final VoidCallback? onFamilyMembers;
  final VoidCallback? onReturnChecklist;

  @override
  State<HomeTripCard> createState() => _HomeTripCardState();
}

class _HomeTripCardState extends State<HomeTripCard> {
  static const _notch = 22.0;
  static const _radius = 18.0;

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final colors = TripTypeColors.of(trip.type);

    return LayoutBuilder(
      builder: (context, constraints) {
        // On phones the date stub narrows so the trip details keep room.
        final compact = constraints.maxWidth < 440;
        final stubWidth = compact ? 100.0 : 140.0;

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
                  child: Semantics(
                    button: true,
                    label: trip.semanticsLabel,
                    child: InkWell(
                      onTap: widget.onTap,
                      hoverColor: Colors.transparent,
                      // At least homeCardHeight, taller if the text needs it
                      // (long names, large system text sizes).
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: homeCardHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _TicketBody(
                                  trip: trip,
                                  colors: colors,
                                  compact: compact,
                                  onFamilyMembers: widget.onFamilyMembers,
                                  onReturnChecklist: widget.onReturnChecklist,
                                ),
                              ),
                              const _Perforation(),
                              _TicketStub(
                                trip: trip,
                                colors: colors,
                                width: stubWidth,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Half-circle notches where the ticket would tear, painted in
                // the page colour so they read as cut-outs.
                for (final top in [true, false])
                  Positioned(
                    right: stubWidth - _notch / 2,
                    top: top ? -_notch / 2 : null,
                    bottom: top ? null : -_notch / 2,
                    child: const IgnorePointer(child: _Notch(size: _notch)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({
    required this.trip,
    required this.colors,
    required this.compact,
    this.onFamilyMembers,
    this.onReturnChecklist,
  });

  final HomeTrip trip;
  final TripTypeColors colors;
  final bool compact;
  final VoidCallback? onFamilyMembers;
  final VoidCallback? onReturnChecklist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 28,
        18,
        compact ? 14 : 22,
        10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  trip.typeLabel,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.eyebrow(colors.onTint),
                ),
              ),
              if (trip.reminderLabel != null) ...[
                const SizedBox(width: 10),
                _ReminderBadge(label: trip.reminderLabel!),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            trip.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.cardTitle.copyWith(
              fontSize: compact ? 21 : 26,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            trip.details,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const Spacer(),
          _ProgressLine(trip: trip),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: [
              _CardLink(
                icon: Icons.people_outline,
                label: 'Family members',
                onPressed: onFamilyMembers,
              ),
              _CardLink(
                icon: Icons.assignment_return_outlined,
                label: 'Return checklist',
                onPressed: onReturnChecklist,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "26 of 42 packed" with a slim bar and the percentage, or a clear note when
/// the trip has no items yet or its items could not be loaded.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.trip});

  final HomeTrip trip;

  @override
  Widget build(BuildContext context) {
    if (trip.progressUnavailable) {
      return const Row(
        children: [
          Icon(Icons.error_outline, size: 15, color: AppColors.error),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Couldn’t load packing progress',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      );
    }
    final label = trip.totalCount == 0
        ? 'No items yet'
        : '${trip.packedCount} of ${trip.totalCount} packed';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${trip.percent}%',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: trip.progress, minHeight: 5),
        ),
      ],
    );
  }
}

/// Small bell + time shown next to the trip type when a reminder is on.
class _ReminderBadge extends StatelessWidget {
  const _ReminderBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            size: 13,
            color: Color(0xFF7A5A00),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A5A00),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact text link along the bottom of a trip card.
class _CardLink extends StatelessWidget {
  const _CardLink({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontFamily: AppText.sans,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
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
