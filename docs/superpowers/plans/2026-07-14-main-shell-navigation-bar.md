# Main Shell NavigationBar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `MainShell`'s `CustomBottomNav` with Material 3 `NavigationBar`, with coral primary selection chrome configured once in `AppTheme.navigationBarTheme`.

**Architecture:** Global `NavigationBarThemeData` in `AppTheme._buildTheme` drives colors. `MainShell` mounts a `NavigationBar` with three `NavigationDestination`s and the same `go()` routing as today. Clipboard keeps `CustomBottomNav`.

**Tech Stack:** Flutter Material 3 (`NavigationBar`, `NavigationBarThemeData`, `WidgetStateProperty`)

**Spec:** `docs/superpowers/specs/2026-07-14-main-shell-navigation-bar-design.md`

**Working directory:** repo root (`d:\lbs\demo\sebhua-notes-app`)

## Global Constraints

- Implement on `master` only — no feature branches / worktrees unless the user explicitly asks.
- Do not add automated tests unless the user asks (manual QA for this phase).
- Do not hardcode `#ed6f5c` in the shell widget — use `ColorScheme` / theme only.
- MainShell only — do not change clipboard bottom bar or delete `CustomBottomNav`.
- Wide layout (≥600): keep `bottomNavigationBar: null`.
- Do not change notes filter tabs, shell route table, or add clipboard back to the bar.

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/ui/theme/app_theme.dart` | `navigationBarTheme` (primary indicator / selected colors) |
| `lib/ui/shell/main_shell.dart` | `NavigationBar` destinations + routing |
| `lib/ui/components/custom_bottom_nav.dart` | Unchanged (clipboard) |

---

### Task 1: `NavigationBarTheme` in AppTheme

**Files:**
- Modify: `lib/ui/theme/app_theme.dart` (inside `_buildTheme`, near existing `navigationRailTheme`)

**Interfaces:**
- Consumes: `ColorScheme scheme`, `TextTheme textTheme` already in `_buildTheme`
- Produces: theme-level `navigationBarTheme` consumed by any `NavigationBar`

- [ ] **Step 1: Add `navigationBarTheme`**

In `_buildTheme`, after `navigationRailTheme: ... ,` insert:

```dart
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary, size: 24);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = textTheme.labelMedium;
          if (states.contains(WidgetState.selected)) {
            return base?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return base?.copyWith(color: scheme.onSurfaceVariant);
        }),
      ),
```

Do not change light/dark wrappers beyond what `_buildTheme` already shares.

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/ui/theme/app_theme.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```powershell
git add lib/ui/theme/app_theme.dart
git commit -m "style: theme NavigationBar with primary coral selection"
```

---

### Task 2: MainShell → `NavigationBar`

**Files:**
- Modify: `lib/ui/shell/main_shell.dart`

**Interfaces:**
- Consumes: `AppTheme.navigationBarTheme` (from Task 1); existing `AppConstants` routes + `UiStrings`
- Produces: same shell routing behavior with Material `NavigationBar`

- [ ] **Step 1: Replace CustomBottomNav with NavigationBar**

Replace the full contents of `lib/ui/shell/main_shell.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';

/// App shell with bottom tabs: notes / drafts / settings.
///
/// Clipboard stays a deep-link-only route and is not shown here.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith(AppConstants.routeSettings)) return 2;
    if (location.startsWith(AppConstants.routeDrafts)) return 1;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go(AppConstants.routeHome);
      case 1:
        context.go(AppConstants.routeDrafts);
      case 2:
        context.go(AppConstants.routeSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexForLocation(location);
    final wide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      body: child,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => _onDestinationSelected(context, i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.note_outlined),
                  selectedIcon: Icon(Icons.note),
                  label: UiStrings.navNotes,
                ),
                NavigationDestination(
                  icon: Icon(Icons.drafts_outlined),
                  selectedIcon: Icon(Icons.drafts),
                  label: UiStrings.navDrafts,
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: UiStrings.navSettings,
                ),
              ],
            ),
    );
  }
}
```

Remove the `custom_bottom_nav.dart` import. Do not delete `custom_bottom_nav.dart`.

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/ui/shell/main_shell.dart lib/ui/theme/app_theme.dart
```

Expected: No issues found.

- [ ] **Step 3: Manual QA**

Hot-restart the running Chrome session (or `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000`):

1. Narrow: Material `NavigationBar` with 笔记 / 草稿 / 设置; taps navigate correctly.
2. Selected destination uses coral primary indicator / accent (not the old custom bar).
3. Resize ≥600: bottom bar disappears.
4. Open `/clipboard` if reachable: still shows `CustomBottomNav` (unchanged).

- [ ] **Step 4: Commit**

```powershell
git add lib/ui/shell/main_shell.dart
git commit -m "feat: use Material NavigationBar in MainShell"
```

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Global `navigationBarTheme` with primary selection | Task 1 |
| MainShell `NavigationBar` + three destinations | Task 2 |
| Same icons / labels / `go()` routes | Task 2 |
| Wide ≥600: no bar | Task 2 |
| Clipboard / `CustomBottomNav` unchanged | Global Constraints + Task 2 |
| No hardcoded `#ed6f5c` in shell | Task 2 uses theme only |
| Manual QA | Task 2 Step 3 |
