import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the current [ThemeMode] and exposes methods to change it.
///
/// The initial value is [ThemeMode.system] so the app respects the
/// OS-level dark-mode setting on first launch.  Call [toggle] to flip
/// between light and dark, or [set] to pick an explicit mode.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Switches to the opposite of the *effective* mode.
  ///
  /// When the current mode is [ThemeMode.system] the toggle uses the
  /// platform brightness to decide which way to flip, so the user
  /// always sees a visible change.
  void toggle() {
    final current = state == ThemeMode.system
        ? _systemBrightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light
        : state;
    state = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// Sets an explicit [ThemeMode].
  void set(ThemeMode mode) {
    state = mode;
  }

  /// Resets to following the OS setting.
  void resetToSystem() {
    state = ThemeMode.system;
  }

  /// Whether the effective theme is dark.
  bool get isDark {
    if (state == ThemeMode.system) {
      return _systemBrightness == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }

  Brightness get _systemBrightness =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
}

/// Provider that exposes the current [ThemeMode] and lets widgets
/// change it.
///
/// Usage in a widget:
/// ```dart
/// final themeMode = ref.watch(themeModeProvider);
/// ref.read(themeModeProvider.notifier).toggle();
/// ```
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);