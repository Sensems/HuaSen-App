import 'package:flutter/material.dart';

/// Centralized text styles for sebhua_notes.
///
/// All text in the app should use one of these styles (or a
/// [TextTheme] built from them via [AppTheme]).  Never hardcode
/// `TextStyle(...)` in widget code.
///
/// The scale is tuned for long-form reading and writing:
/// - Body text is slightly larger than Material defaults for comfort.
/// - Line height is generous to reduce eye strain.
/// - Headings use weight 600 (semibold) rather than 700 for a softer
///   editorial feel.
class AppTypography {
  AppTypography._();

  /// Base font family.  Falls back to the platform default if the
  /// bundled font is unavailable.
  static const String fontFamily = 'Georgia';

  /// Monospace font for code snippets inside notes.
  static const String monoFontFamily = 'Courier New';

  // ── Display / Headlines ───────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  // ── Titles ───────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // ── Body ─────────────────────────────────────────────────────
  /// Primary body style for note content — the most-used style.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Labels / Captions ────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ── Monospace (code in notes) ────────────────────────────────
  static const TextStyle codeMedium = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── TextTheme builders ───────────────────────────────────────

  /// Builds a [TextTheme] from the styles above.
  ///
  /// Colors are intentionally left unset here — they are applied by
  /// [AppTheme] via [ColorScheme] so that text automatically adapts
  /// to light/dark mode.
  static TextTheme textTheme(ColorScheme scheme) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: scheme.onSurface),
      displayMedium: displayMedium.copyWith(color: scheme.onSurface),
      displaySmall: displaySmall.copyWith(color: scheme.onSurface),
      headlineLarge: headlineLarge.copyWith(color: scheme.onSurface),
      headlineMedium: headlineMedium.copyWith(color: scheme.onSurface),
      headlineSmall: headlineSmall.copyWith(color: scheme.onSurface),
      titleLarge: titleLarge.copyWith(color: scheme.onSurface),
      titleMedium: titleMedium.copyWith(color: scheme.onSurface),
      titleSmall: titleSmall.copyWith(color: scheme.onSurface),
      bodyLarge: bodyLarge.copyWith(color: scheme.onSurface),
      bodyMedium: bodyMedium.copyWith(color: scheme.onSurface),
      bodySmall: bodySmall.copyWith(color: scheme.onSurfaceVariant),
      labelLarge: labelLarge.copyWith(color: scheme.onSurface),
      labelMedium: labelMedium.copyWith(color: scheme.onSurfaceVariant),
      labelSmall: labelSmall.copyWith(color: scheme.onSurfaceVariant),
    );
  }
}