# Main Shell NavigationBar

**Date:** 2026-07-14  
**Status:** Approved for planning  
**Scope:** Replace `MainShell` custom bottom nav with Material 3 `NavigationBar`; theme colors via global `NavigationBarTheme`

## Goal

Use Material `NavigationBar` for the shell tabs (笔记 / 草稿 / 设置), with selection chrome driven by `ColorScheme.primary` (`#ed6f5c`), configured once in `AppTheme`.

## Decisions

| Topic | Choice |
|-------|--------|
| Approach | Inline `NavigationBar` in `MainShell` + `navigationBarTheme` in `AppTheme` |
| Selection style | Theme primary (coral) for indicator / selected icon & label |
| Scope | MainShell only — clipboard keeps `CustomBottomNav` |
| Wide layout | Unchanged: no bottom bar when width ≥ 600 |
| CustomBottomNav file | Keep (still used by clipboard) |

## Design

### Global theme

In `AppTheme._buildTheme`, add `NavigationBarThemeData` so light and dark share:

- `backgroundColor`: `scheme.surface`
- `indicatorColor`: coral-tinted pill via `scheme.primary` at ~15–20% opacity (reads as brand, keeps icons readable)
- Selected icon & label: `scheme.primary`
- Unselected icon & label: `scheme.onSurfaceVariant`
- Height / label behavior: Material 3 defaults (`NavigationDestinationLabelBehavior` unchanged)

Do **not** hardcode `#ed6f5c` in the shell widget; read from `ColorScheme` / theme only.

### MainShell

Replace `CustomBottomNav` with:

```dart
NavigationBar(
  selectedIndex: index,
  onDestinationSelected: (i) { /* same go() switches as today */ },
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.note_outlined),
      selectedIcon: Icon(Icons.note),
      label: UiStrings.navNotes,
    ),
    // drafts, settings — same icons/labels as current CustomNavItem list
  ],
)
```

Keep:

- `_indexForLocation` mapping
- Wide breakpoint: `bottomNavigationBar: wide ? null : NavigationBar(...)`
- Three destinations only (clipboard remains deep-link, not in the bar)

### Out of scope

- Clipboard screen bottom bar
- Deleting or rewriting `CustomBottomNav`
- Notes list filter tabs (`NotesFilterTabs`)
- Shell route table / adding clipboard back to the bar
- NavigationRail for wide layouts (still no bottom bar only)

## Architecture

```
AppTheme.navigationBarTheme  →  colors for all NavigationBar instances
MainShell.bottomNavigationBar →  NavigationBar (narrow only)
ClipboardHistoryScreen        →  CustomBottomNav (unchanged)
```

## Verification (manual)

1. Narrow: three destinations; tap switches notes / drafts / settings.
2. Selected destination shows coral primary indicator / accent.
3. Wide (≥600): no bottom bar.
4. Clipboard route still shows previous custom bar if opened.
5. `flutter analyze` clean on touched files.

## Files likely touched

- `lib/ui/theme/app_theme.dart`
- `lib/ui/shell/main_shell.dart`
