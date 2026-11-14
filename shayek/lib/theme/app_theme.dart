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

/// Serif display type for headings over a clean sans body.
abstract final class AppText {
  static const _serif = 'Georgia';
  static const _serifFallback = ['serif'];

  static const display = TextStyle(
    color: AppColors.ink,
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 44,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.6,
  );

  static const title = TextStyle(
    color: AppColors.ink,
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const cardTitle = TextStyle(
    color: AppColors.ink,
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const brand = TextStyle(
    color: AppColors.ink,
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 25,
    fontWeight: FontWeight.w700,
  );

  static const lead = TextStyle(
    color: AppColors.muted,
    fontSize: 17,
    height: 1.5,
  );

  static const body = TextStyle(color: AppColors.ink, fontSize: 15);
  static const muted = TextStyle(color: AppColors.muted, fontSize: 14);
  static const label = TextStyle(
    color: AppColors.ink,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Small bold label above a card title (e.g. the trip type).
  static TextStyle eyebrow(Color color) => TextStyle(
    color: color,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
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
          fontFamily: 'Georgia',
          fontFamilyFallback: ['serif'],
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
          fontFamily: 'Georgia',
          fontFamilyFallback: ['serif'],
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
