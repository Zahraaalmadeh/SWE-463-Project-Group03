import 'package:flutter/material.dart';

import '../models/trip.dart';

/// Shayek's palette: warm paper background, deep-blue actions, and a
/// tangerine accent used sparingly for emphasis.
abstract final class AppColors {
  static const background = Color(0xFFF7F4EE);
  static const surface = Colors.white;
  static const sand = Color(0xFFF1ECE3);
  static const line = Color(0xFFE7E1D6);
  static const divider = Color(0xFFF0EBE2);
  static const fieldBorder = Color(0xFFD9D1C3);
  static const ink = Color(0xFF1E2430);
  static const muted = Color(0xFF5F6673);
  static const primary = Color(0xFF1F4E8C);
  static const primaryDark = Color(0xFF163A69);
  static const accent = Color(0xFFF08A4B);
  static const highlight = Color(0xFFFBD87F);
  static const packed = Color(0xFF2F6B3A);
  static const shared = Color(0xFF1F5F99);
  static const error = Color(0xFFB42318);
}

/// Soft background + readable foreground for each trip type, so a trip is
/// recognisable by colour across Home, the checklist and saved lists.
class TripTypeColors {
  const TripTypeColors(this.tint, this.onTint);

  final Color tint;
  final Color onTint;

  static TripTypeColors of(TripType type) => switch (type) {
    TripType.beach => const TripTypeColors(
      Color(0xFFDCEBF7),
      Color(0xFF174A78),
    ),
    TripType.business => const TripTypeColors(
      Color(0xFFE6E3F3),
      Color(0xFF3A3070),
    ),
    TripType.family => const TripTypeColors(
      Color(0xFFFCE3D3),
      Color(0xFF7A3412),
    ),
    TripType.camping => const TripTypeColors(
      Color(0xFFDDEEDC),
      Color(0xFF24552D),
    ),
    TripType.city => const TripTypeColors(Color(0xFFF1E7D3), Color(0xFF5E4413)),
    TripType.other => const TripTypeColors(
      Color(0xFFECEAE6),
      Color(0xFF3D4047),
    ),
  };
}

/// Fraunces (serif) for headings over DM Sans for body text. Both are
/// bundled in assets/fonts and registered in pubspec.yaml.
abstract final class AppText {
  static const serif = 'Fraunces';
  static const sans = 'DM Sans';
  static const _serifFallback = ['Georgia', 'serif'];

  /// Page heading, e.g. "Your trips".
  static const display = TextStyle(
    color: AppColors.ink,
    fontFamily: serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 52,
    fontWeight: FontWeight.w500,
    height: 1.05,
    letterSpacing: -1.04,
  );

  /// Section heading, e.g. "Search packing lists".
  static const title = TextStyle(
    color: AppColors.ink,
    fontFamily: serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 34,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: -0.34,
  );

  /// Card heading, e.g. a list name.
  static const cardTitle = TextStyle(
    color: AppColors.ink,
    fontFamily: serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const brand = TextStyle(
    color: AppColors.ink,
    fontFamily: serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.26,
  );

  static const lead = TextStyle(
    color: AppColors.muted,
    fontSize: 18,
    height: 1.55,
  );

  static const body = TextStyle(color: AppColors.ink, fontSize: 15);
  static const muted = TextStyle(color: AppColors.muted, fontSize: 14);
  static const label = TextStyle(
    color: AppColors.ink,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Small uppercase label above a card title (e.g. "FAMILY TRIP").
  static TextStyle eyebrow(Color color) => TextStyle(
    color: color,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.04,
  );
}

/// A heading where one word sits on a yellow highlighter stroke covering the
/// lower part of the letters, e.g. "Your **trips**".
class HighlightedHeading extends StatelessWidget {
  const HighlightedHeading({
    super.key,
    required this.before,
    required this.highlighted,
    this.style = AppText.display,
  });

  final String before;
  final String highlighted;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    TextPainter measure(String text) => TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    // Measure where the highlighted word sits on the line, then draw the
    // marker stroke behind it, from 62% to 92% of the line height.
    final full = measure(before + highlighted);
    final lead = measure(before);
    final lineHeight = full.height;
    const pad = 4.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: lead.width - pad,
          width: full.width - lead.width + pad * 2,
          top: lineHeight * 0.62,
          height: lineHeight * 0.30,
          child: const ColoredBox(color: AppColors.highlight),
        ),
        Text(before + highlighted, style: style),
      ],
    );
  }
}

/// Page widths and gutters shared by every screen.
abstract final class AppLayout {
  /// Outer width of the top bar and wide pages, including [pagePadding].
  static const pageWidth = 1160.0;
  static const pagePadding = 40.0;

  /// Side gutter for the current window: 40px, or 20px on phones.
  static double gutter(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600 ? 20 : pagePadding;
}

abstract final class AppTheme {
  static const pill = StadiumBorder();

  static ThemeData build() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          error: AppColors.error,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.muted,
          outline: AppColors.fieldBorder,
          outlineVariant: AppColors.line,
          surfaceContainerHighest: AppColors.sand,
        );

    OutlineInputBorder border(Color color, [double width = 1.5]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppText.sans,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.line,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontFamily: AppText.serif,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: pill,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.ink, width: 1.5),
          shape: pill,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: pill,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: pill,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hoverColor: Colors.transparent,
        hintStyle: const TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: border(AppColors.fieldBorder),
        enabledBorder: border(AppColors.fieldBorder),
        focusedBorder: border(AppColors.primary, 2),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.ink,
        disabledColor: AppColors.sand,
        checkmarkColor: Colors.white,
        labelStyle: const TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
        shape: pill,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const CircleBorder(),
        side: const BorderSide(color: Color(0xFFB9AF9F), width: 2),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.packed
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.sand,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: Color(0xFFE9E2D6),
        circularTrackColor: Color(0xFFE9E2D6),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: const TextStyle(
          color: AppColors.ink,
          fontFamily: AppText.serif,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.line),
        ),
        textStyle: const TextStyle(color: AppColors.ink, fontSize: 15),
      ),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.muted),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: StadiumBorder(),
        insetPadding: EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
