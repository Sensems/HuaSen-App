# Notes List Search Bar Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Polish the notes-list expandable search: remove the close button, collapse only when empty + unfocused, kill TextField focus rings, and add right inset padding.

**Architecture:** Local changes only inside `ExpandableSearchButton`. Parent still owns `TextEditingController` and wires `onSubmit` / `onCollapsedClear` to `NotesListNotifier`. Blur-driven collapse uses a `FocusNode` listener; empty collapse always calls `onCollapsedClear` (notifier `clearSearch` no-ops when keyword is already empty).

**Tech Stack:** Flutter, Material `FocusNode` / `TextField` / `AnimatedContainer`

**Spec:** `docs/superpowers/specs/2026-07-14-notes-list-search-bar-design.md`

**Working directory for all Flutter commands:** repo root (`d:\lbs\demo\sebhua-notes-app`)

## Global Constraints

- Implement on `master` only — no feature branches / worktrees unless the user explicitly asks.
- Do not add automated tests unless the user asks (manual QA for this phase).
- Do not change global `AppTheme` / `InputDecorationTheme`.
- Do not change notes list API, pagination, filter tabs, or shell navigation.
- Keep outer capsule fill + outline; only remove TextField borders / focus rings.

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/features/notes/widgets/expandable_search_button.dart` | Expand/collapse UI, focus listener, borders, padding, no close button |
| `lib/features/notes/notes_list_screen.dart` | Unchanged unless analyze reveals dead wiring (prefer leave as-is) |

---

### Task 1: ExpandableSearchButton focus/collapse + visual polish

**Files:**
- Modify: `lib/features/notes/widgets/expandable_search_button.dart`

**Interfaces:**
- Consumes: existing `controller`, `onSubmit`, `onCollapsedClear` (signatures unchanged)
- Produces: same public API; behavior changes only inside the State class

- [ ] **Step 1: Replace collapse/focus logic and expanded UI**

Rewrite `lib/features/notes/widgets/expandable_search_button.dart` to match the following (keep `_elevatedSearchFill` and collapsed tap→expand behavior):

```dart
import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../../../ui/theme/app_colors.dart';

Color _elevatedSearchFill(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.light
      ? AppColors.lightSurface
      : AppColors.darkSurface;
}

/// Compact search control that expands into a keyword field.
///
/// Collapsed: square icon button. Expanded: animated field with search submit.
/// Empty + unfocused collapses; non-empty unfocused stays expanded.
/// Parent owns [controller] and search side effects.
class ExpandableSearchButton extends StatefulWidget {
  const ExpandableSearchButton({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onCollapsedClear,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCollapsedClear;

  @override
  State<ExpandableSearchButton> createState() => _ExpandableSearchButtonState();
}

class _ExpandableSearchButtonState extends State<ExpandableSearchButton> {
  static const double _collapsedSize = 40;
  static const double _maxExpandedWidth = 220;
  static const double _expandedRightInset = 12;

  bool _expanded = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus || !_expanded) return;
    if (widget.controller.text.trim().isNotEmpty) return;

    setState(() => _expanded = false);
    // clearSearch() no-ops when keyword is already empty.
    widget.onCollapsedClear();
  }

  void _expand() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  double _widthForConstraints(BoxConstraints constraints) {
    if (!_expanded) return _collapsedSize;

    final maxWidth = constraints.maxWidth;
    if (!maxWidth.isFinite) return _maxExpandedWidth;

    return maxWidth.clamp(_collapsedSize, _maxExpandedWidth);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: _widthForConstraints(constraints),
          height: _collapsedSize,
          decoration: BoxDecoration(
            color: _elevatedSearchFill(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: _expanded
              ? _buildExpanded(colorScheme)
              : _buildCollapsed(colorScheme),
        );
      },
    );
  }

  Widget _buildCollapsed(ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _expand,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildExpanded(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(right: _expandedRightInset),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => widget.onSubmit(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
              decoration: InputDecoration(
                isDense: true,
                hintText: UiStrings.searchNotesHint,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              Icons.search,
              size: 20,
              color: colorScheme.primary,
            ),
            onPressed: widget.onSubmit,
            tooltip: UiStrings.searchNotes,
          ),
        ],
      ),
    );
  }
}
```

Key behavior to preserve while editing:
- No `Icons.close` / `_collapseAndClear`.
- Outer capsule `BoxDecoration.border` stays.
- All TextField border variants are `InputBorder.none`.
- Right inset constant `_expandedRightInset = 12`.

- [ ] **Step 2: Analyze the touched file**

Run:

```bash
dart analyze lib/features/notes/widgets/expandable_search_button.dart
```

Expected: no issues (or only pre-existing unrelated infos).

- [ ] **Step 3: Manual QA on notes list**

Run (or hot-restart existing session):

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Checklist (must all pass):

1. Expand search → no close (X) button; search icon has comfortable space to the right capsule edge.
2. Focus the field → no terracotta / primary focus ring on the input; outer capsule outline still visible.
3. Type a keyword → tap elsewhere (blur) → control stays expanded with text.
4. Clear the text → blur → control collapses to icon; if a search was active, list reloads without keyword (`clearSearch`).
5. Submit still works via trailing search icon and keyboard Search.

- [ ] **Step 4: Commit**

```bash
git add lib/features/notes/widgets/expandable_search_button.dart
git commit -m "$(cat <<'EOF'
fix: polish notes list expandable search focus and chrome

Collapse only when empty and unfocused, drop the close control, and suppress TextField focus borders while keeping the outer capsule.
EOF
)"
```

On Windows PowerShell if heredoc is unavailable:

```powershell
git add lib/features/notes/widgets/expandable_search_button.dart
git commit -m "fix: polish notes list expandable search focus and chrome"
```

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Remove close button | Task 1 |
| Increase right inset | Task 1 (`_expandedRightInset`) |
| Click collapsed → expand + focus | Task 1 (`_expand`) |
| Empty + blur → collapse + clearSearch | Task 1 (`_onFocusChange`) |
| Non-empty + blur → stay expanded | Task 1 |
| TextField borders none; outer capsule kept | Task 1 |
| Submit via icon / keyboard unchanged | Task 1 |
| No global theme change | Global Constraints + Task 1 |
| Manual QA only | Task 1 Step 3 |

No placeholders remain. Public widget API unchanged — `notes_list_screen.dart` needs no edit.
