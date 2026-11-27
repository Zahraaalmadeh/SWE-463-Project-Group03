import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/packing_template.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';

/// Collects the details of a new trip before its packing list is generated.
class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key, this.template});

  final PackingTemplate? template;

  static const minDurationDays = 1;
  static const maxDurationDays = 90;
  static const minTravelers = 1;
  static const maxTravelers = 20;
  static const maxNameLength = 60;

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _nameController = TextEditingController();
  final _nameFieldKey = GlobalKey();
  final _dateFieldKey = GlobalKey();
  TripType _selectedType = TripType.beach;
  int _durationDays = 5;
  int _travelerCount = 2;
  DateTime? _departureDate;
  String? _nameError;
  String? _dateError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    if (template != null) {
      _nameController.text = template.name;
      _selectedType = template.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _Header(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    children: [
                      Text(
                        'Where are you headed?',
                        // Big on desktop, compact on phones so the form's
                        // counters stay on screen without scrolling.
                        style: MediaQuery.sizeOf(context).width >= 600
                            ? _Text.heading
                            : _Text.heading.copyWith(fontSize: 30),
                      ),
                      if (widget.template != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.highlight,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              child: Text(
                                'Using list · ${widget.template!.name}',
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      const _FieldLabel('Trip name'),
                      TextField(
                        key: _nameFieldKey,
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            CreateTripScreen.maxNameLength,
                          ),
                        ],
                        style: _Text.input,
                        decoration: _inputDecoration(errorText: _nameError),
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = _validateName());
                          }
                        },
                      ),
                      const SizedBox(height: 28),
                      const _FieldLabel('Trip type'),
                      _TripTypeGrid(
                        selected: _selectedType,
                        onSelected: (type) =>
                            setState(() => _selectedType = type),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _Counter(
                              label: 'Duration (days)',
                              value: _durationDays,
                              onDecrement: () =>
                                  setState(() => _durationDays--),
                              onIncrement: () =>
                                  setState(() => _durationDays++),
                              canDecrement:
                                  _durationDays >
                                  CreateTripScreen.minDurationDays,
                              canIncrement:
                                  _durationDays <
                                  CreateTripScreen.maxDurationDays,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _Counter(
                              label: 'Travelers',
                              value: _travelerCount,
                              onDecrement: () =>
                                  setState(() => _travelerCount--),
                              onIncrement: () =>
                                  setState(() => _travelerCount++),
                              canDecrement:
                                  _travelerCount >
                                  CreateTripScreen.minTravelers,
                              canIncrement:
                                  _travelerCount <
                                  CreateTripScreen.maxTravelers,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const _FieldLabel('Departure date'),
                      _DateField(
                        key: _dateFieldKey,
                        date: _departureDate,
                        errorText: _dateError,
                        onTap: _pickDepartureDate,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: _GenerateButton(
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDepartureDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = _departureDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current == null || current.isBefore(today) ? today : current,
      firstDate: today,
      lastDate: DateTime(today.year + 5, today.month, today.day),
      helpText: 'Select departure date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme
              .copyWith(primary: _Palette.primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _departureDate = picked;
      _dateError = null;
    });
  }

  String? _validateName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return 'Please enter a trip name.';
    return null;
  }

  String? _validateDate() {
    final date = _departureDate;
    if (date == null) return 'Please choose a departure date.';
    final now = DateTime.now();
    if (date.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Departure date cannot be in the past.';
    }
    return null;
  }

  /// Scrolls the first invalid field into view so its message is visible on
  /// short screens.
  void _revealFirstError() {
    final key = _nameError != null ? _nameFieldKey : _dateFieldKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fieldContext = key.currentContext;
      if (fieldContext == null || !fieldContext.mounted) return;
      Scrollable.ensureVisible(
        fieldContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Validates every required input and shows inline errors for any that fail.
  bool _validate() {
    final nameError = _validateName();
    final dateError = _validateDate();
    final durationValid =
        _durationDays >= CreateTripScreen.minDurationDays &&
        _durationDays <= CreateTripScreen.maxDurationDays;
    final travelersValid =
        _travelerCount >= CreateTripScreen.minTravelers &&
        _travelerCount <= CreateTripScreen.maxTravelers;
    setState(() {
      _nameError = nameError;
      _dateError = dateError;
    });
    return nameError == null &&
        dateError == null &&
        durationValid &&
        travelersValid;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) {
      _revealFirstError();
      return;
    }

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final trip = await context.read<TripProvider>().createTrip(
        name: _nameController.text,
        type: _selectedType,
        durationDays: _durationDays,
        departureDate: _departureDate!,
        travelerCount: _travelerCount,
        listId: null,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('"${trip.name}" was saved.')),
      );
      // Hand the saved trip to the packing checklist feature. Replacing this
      // route means Back from the checklist returns to Home, not the form.
      await navigator.pushReplacementNamed(
        AppRoutes.checklist,
        arguments: ChecklistRouteArgs(trip: trip, template: widget.template),
      );
    } catch (error) {
      debugPrint('Failed to create trip: $error');
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not save your trip. Please try again.'),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({String? errorText}) {
    OutlineInputBorder border(Color color, [double width = 1.5]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: 'e.g. Summer in Santorini',
      hintStyle: _Text.hint,
      errorText: errorText,
      filled: true,
      fillColor: _Palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: border(_Palette.border),
      focusedBorder: border(_Palette.primary, 2),
      errorBorder: border(_Palette.error),
      focusedErrorBorder: border(_Palette.error, 2),
    );
  }
}

const double _radius = 14;

abstract final class _Palette {
  static const background = AppColors.background;
  static const surface = AppColors.surface;
  static const border = AppColors.fieldBorder;
  static const ink = AppColors.ink;
  static const muted = AppColors.muted;
  static const primary = AppColors.primary;
  static const counterFill = AppColors.sand;
  static const error = AppColors.error;
}

abstract final class _Text {
  static const title = TextStyle(
    color: _Palette.muted,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );
  static final heading = AppText.display.copyWith(fontSize: 46);
  static const label = AppText.label;
  static const input = TextStyle(color: _Palette.ink, fontSize: 17);
  static const hint = TextStyle(color: _Palette.muted, fontSize: 17);
  static const error = TextStyle(color: _Palette.error, fontSize: 12);
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 48,
      child: Row(
        children: [
          _BackButton(),
          SizedBox(width: 14),
          Text('New Trip', style: _Text.title),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Palette.surface,
      shape: const CircleBorder(
        side: BorderSide(color: _Palette.border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        child: const SizedBox.square(
          dimension: 44,
          child: Icon(
            Icons.arrow_back,
            color: _Palette.ink,
            size: 20,
            semanticLabel: 'Back',
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: _Text.label),
    );
  }
}

class _TripTypeOption {
  const _TripTypeOption(this.type, this.label, this.icon);

  final TripType type;
  final String label;
  final Widget icon;
}

const _tripTypeOptions = [
  _TripTypeOption(TripType.beach, 'Beach', _BeachUmbrellaIcon()),
  _TripTypeOption(TripType.business, 'Business', Icon(Icons.work_outline)),
  _TripTypeOption(TripType.family, 'Family', Icon(Icons.people_outline)),
  _TripTypeOption(TripType.camping, 'Camping', _TentIcon()),
  _TripTypeOption(TripType.city, 'City', Icon(Icons.location_city_outlined)),
  _TripTypeOption(TripType.other, 'Other', Icon(Icons.explore_outlined)),
];

class _TripTypeGrid extends StatelessWidget {
  const _TripTypeGrid({required this.selected, required this.onSelected});

  final TripType selected;
  final ValueChanged<TripType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in _tripTypeOptions)
          _TripTypeTile(
            option: option,
            selected: option.type == selected,
            onTap: () => onSelected(option.type),
          ),
      ],
    );
  }
}

class _TripTypeTile extends StatelessWidget {
  const _TripTypeTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _TripTypeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected
        ? AppColors.highlight
        : TripTypeColors.of(option.type).onTint;

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: selected ? _Palette.ink : _Palette.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? _Palette.ink : _Palette.border,
              width: 1.5,
            ),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: iconColor, size: 20),
                    child: option.icon,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    option.label,
                    style: TextStyle(
                      color: selected ? Colors.white : _Palette.ink,
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Material's open beach umbrella is drawn tilted; stand it upright to match
/// the design.
class _BeachUmbrellaIcon extends StatelessWidget {
  const _BeachUmbrellaIcon();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: const Icon(Icons.beach_access_outlined),
    );
  }
}

/// Outline tent glyph; Material Icons has no camping tent.
class _TentIcon extends StatelessWidget {
  const _TentIcon();

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size ?? 24;
    return CustomPaint(
      size: Size.square(size),
      painter: _TentPainter(theme.color ?? _Palette.ink),
    );
  }
}

class _TentPainter extends CustomPainter {
  const _TentPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      // Outer canopy, including the crossed poles at the peak.
      ..drawLine(Offset(9.5 * s, 2.5 * s), Offset(20.5 * s, 20.5 * s), paint)
      ..drawLine(Offset(14.5 * s, 2.5 * s), Offset(3.5 * s, 20.5 * s), paint)
      // Doorway.
      ..drawPath(
        Path()
          ..moveTo(8.5 * s, 20.5 * s)
          ..lineTo(12 * s, 14 * s)
          ..lineTo(15.5 * s, 20.5 * s),
        paint,
      )
      // Ground.
      ..drawLine(Offset(2 * s, 20.5 * s), Offset(22 * s, 20.5 * s), paint);
  }

  @override
  bool shouldRepaint(_TentPainter oldDelegate) => oldDelegate.color != color;
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.canDecrement,
    required this.canIncrement,
  });

  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool canDecrement;
  final bool canIncrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        Container(
          height: 56,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _Palette.surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _Palette.border, width: 1.5),
          ),
          child: Row(
            children: [
              _CounterButton(
                icon: Icons.remove,
                tooltip: 'Decrease $label',
                fill: _Palette.counterFill,
                enabled: canDecrement,
                onPressed: onDecrement,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: AppText.cardTitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add,
                tooltip: 'Increase $label',
                fill: _Palette.counterFill,
                enabled: canIncrement,
                onPressed: onIncrement,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.tooltip,
    required this.fill,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color fill;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Material(
          color: fill,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: _Palette.ink, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    super.key,
    required this.date,
    required this.errorText,
    required this.onTap,
  });

  final DateTime? date;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = this.date;
    final text = date == null
        ? 'mm/dd/yyyy'
        : '${_twoDigits(date.month)}/${_twoDigits(date.day)}/${date.year}';

    final errorText = this.errorText;
    final field = Material(
      color: _Palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
        side: BorderSide(
          color: errorText == null ? _Palette.border : _Palette.error,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: _Palette.muted,
                  size: 20,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    text,
                    style: date == null
                        ? _Text.input.copyWith(color: _Palette.muted)
                        : _Text.input,
                  ),
                ),
                const Icon(Icons.calendar_month, color: _Palette.ink, size: 20),
              ],
            ),
          ),
        ),
      ),
    );

    if (errorText == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Text(errorText, style: _Text.error),
        ),
      ],
    );
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome_outlined, size: 22),
        label: const Text('Generate Packing List'),
        style: FilledButton.styleFrom(
          backgroundColor: _Palette.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _Palette.primary,
          disabledForegroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
