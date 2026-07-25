# Filter Task 3 Report: Tab-row filter icon + screen wiring

**Status:** DONE  
**Date:** 2026-07-23  
**Branch:** master (no commit per instructions)

---

## Summary

Wired the category/tag filter icon into the notes list tab row and connected it to `showNotesFilterSheet` via `NotesListScreen`.

---

## Changes

### `lib/features/notes/widgets/notes_filter_tabs.dart`

- Added `onFilterTap` (required) and `hasActiveFilter` (default `false`) parameters.
- Appended trailing `Spacer` + compact `IconButton` with `Icons.filter_list`, tooltip `UiStrings.notesCategoryTagFilterTitle`, and `Badge` dot when `hasActiveFilter` is true.
- Updated class doc comment to mention trailing filter icon.

### `lib/features/notes/notes_list_screen.dart`

- Imported `widgets/notes_filter_sheet.dart`.
- Added `_onCategoryTagFilterTap`: reads current `categoryId`/`tagIds` from provider, opens sheet, applies result via `setCategoryTagFilter` when confirmed and mounted.
- Updated `NotesFilterTabs` call site: right padding `20 → 12`, passed `onFilterTap` and `hasActiveFilter: state.hasCategoryTagFilter`.

---

## Verification

```bash
flutter analyze lib/features/notes/widgets/notes_filter_tabs.dart lib/features/notes/notes_list_screen.dart lib/features/notes/widgets/notes_filter_sheet.dart
```

**Result:** No issues found.

---

## Self-review

| Check | Result |
|-------|--------|
| Matches brief code exactly | Yes — both files use brief-specified snippets verbatim |
| Only allowed files modified | Yes |
| `mounted` guard after async sheet | Yes |
| Null result (dismiss) handled | Yes — early return |
| Badge reflects `hasCategoryTagFilter` from state | Yes |
| Right padding 12 for icon edge clearance | Yes |
| No commit | Yes |

**Concerns:** None.

---

## Manual QA (deferred)

- Tap filter icon → sheet opens with current selections.
- Confirm filter → list reloads with category/tag params; badge appears.
- Clear filter in sheet → badge hides; list reloads unfiltered.
- Dismiss sheet without confirm → no state change.
