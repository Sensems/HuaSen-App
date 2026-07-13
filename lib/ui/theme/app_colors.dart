import 'package:flutter/material.dart';

/// Custom color palette for sebhua_notes.
///
/// The palette is designed for long-form reading and writing:
/// - **Light mode** uses warm paper-like backgrounds with comfortable
///   contrast — never pure white, never pure black.
/// - **Dark mode** uses soft charcoal tones that are easy on the eyes
///   in low-light environments.
/// - The accent is a warm coral that feels natural against both palettes
///   and evokes the warmth of a physical notebook.
///
/// Every color used anywhere in the app should trace back to a value
/// defined here (or to a [ColorScheme] built from these values).  No
/// hardcoded hex codes in widget code.
class AppColors {
  AppColors._();

  // ── Brand / accent ────────────────────────────────────────────
  /// Warm coral — the primary accent across both themes.
  static const Color coral = Color(0xFFED6F5C);

  /// Slightly lighter coral for dark-mode emphasis.
  static const Color coralLight = Color(0xFFF08A7A);

  /// Deep coral for pressed / focused states.
  static const Color coralDark = Color(0xFFD45745);

  /// Cool teal used as a secondary accent (tags, links).
  static const Color teal = Color(0xFF4A9E9E);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF5B8C5A);
  static const Color warning = Color(0xFFC89642);
  static const Color error = Color(0xFFC25450);
  static const Color info = Color(0xFF5B8DB8);

  // ── Light theme surface tones ────────────────────────────────
  /// Page canvas background.
  static const Color lightBackground = Color(0xFFF8F7F4);

  /// Elevated surface (cards, sheets) and input fill — white.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Muted surface for chips, app-bar variants, etc.
  static const Color lightSurfaceVariant = Color(0xFFF0EBE0);

  /// Warm near-black text.
  static const Color lightOnBackground = Color(0xFF2B2722);

  /// Secondary text / captions.
  static const Color lightOnSurfaceVariant = Color(0xFF6B6359);

  /// Subtle dividers and outlines.
  static const Color lightOutline = Color(0xFFD8D0C4);

  // ── Dark theme surface tones ─────────────────────────────────
  /// Soft charcoal background.
  static const Color darkBackground = Color(0xFF1A1816);

  /// Elevated surface.
  static const Color darkSurface = Color(0xFF252320);

  /// Muted surface for input fields, app bars.
  static const Color darkSurfaceVariant = Color(0xFF302D29);

  /// Warm off-white text.
  static const Color darkOnBackground = Color(0xFFEDE7DD);

  /// Secondary text / captions.
  static const Color darkOnSurfaceVariant = Color(0xFFA89F92);

  /// Subtle dividers and outlines.
  static const Color darkOutline = Color(0xFF3D3935);

  // ── ColorScheme builders ──────────────────────────────────────

  /// [ColorScheme] for the light theme.
  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: coral,
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: lightSurfaceVariant,
        onPrimaryContainer: lightOnBackground,
        secondary: teal,
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE0EDED),
        onSecondaryContainer: Color(0xFF1E3A3A),
        tertiary: coralDark,
        onTertiary: Color(0xFFFFFFFF),
        error: error,
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFF8E0DE),
        onErrorContainer: Color(0xFF5C1A18),
        surface: lightBackground,
        onSurface: lightOnBackground,
        surfaceContainerHighest: lightSurfaceVariant,
        onSurfaceVariant: lightOnSurfaceVariant,
        outline: lightOutline,
        outlineVariant: Color(0xFFE8E2D6),
        shadow: Color(0xFF000000),
        scrim: Color(0x99000000),
        inverseSurface: Color(0xFF2B2722),
        onInverseSurface: Color(0xFFF0EBE0),
        inversePrimary: coralLight,
      );

  /// [ColorScheme] for the dark theme.
  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: coralLight,
        onPrimary: Color(0xFF3A2410),
        primaryContainer: Color(0xFF5A3A1E),
        onPrimaryContainer: Color(0xFFF8E8D4),
        secondary: teal,
        onSecondary: Color(0xFF0E2A2A),
        secondaryContainer: Color(0xFF1E3A3A),
        onSecondaryContainer: Color(0xFFB0DCDC),
        tertiary: coral,
        onTertiary: Color(0xFF3A2410),
        error: Color(0xFFE0706C),
        onError: Color(0xFF3A0E0C),
        errorContainer: Color(0xFF5C1A18),
        onErrorContainer: Color(0xFFF8E0DE),
        surface: darkSurface,
        onSurface: darkOnBackground,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkOutline,
        outlineVariant: Color(0xFF4A4640),
        shadow: Color(0xFF000000),
        scrim: Color(0xCC000000),
        inverseSurface: Color(0xFFEDE7DD),
        onInverseSurface: Color(0xFF2B2722),
        inversePrimary: coral,
      );
}