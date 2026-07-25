# Task 2 Report: Independent `NotesFilterSheet`

**Status:** DONE  
**Branch:** master (working-tree only, no commit)  
**Date:** 2026-07-23

## Summary

Created a select-only category/tag filter bottom sheet widget for the notes list. Prefetches categories and tags before opening, mirrors editor picker chip styling, and returns structured results on confirm/clear or `null` on dismiss.

## Changes

### 1. `lib/features/notes/widgets/notes_filter_sheet.dart` (new)

**Public API:**

- `NotesFilterResult` — `{ categoryId?, tagIds }`
- `showNotesFilterSheet(context, { initialCategoryId, initialTagIds })` — prefetch + modal bottom sheet
- `NotesFilterSheet` — stateful sheet content (categories/tags passed in after prefetch)

**Behavior:**

| Action | Return value |
|--------|--------------|
| 确认 | `NotesFilterResult(categoryId: selection, tagIds: selection)` |
| 清除 | `NotesFilterResult(categoryId: null, tagIds: [])` |
| X / barrier dismiss | `null` |
| Prefetch failure | `null` + `$message.error` toast |

**UI:**

- Title: `UiStrings.notesCategoryTagFilterTitle` (筛选)
- Section labels reuse `categoryTagPickerSelectCategory` / `categoryTagPickerSelectTags`
- Compact `ChoiceChip` / `FilterChip` with `AppColors.categorySelected` / `AppColors.tagSelected`, black label text
- Bottom row: secondary「清除」+ primary「确认」via `CustomButton`
- No create/add rows (select-only)
- Max height 85% viewport; scroll when content overflows

**Imports:** Matched editor picker — `category_dto.dart`, `tag_response_dto.dart` (not `category_dtos.dart`).

## Verification

```bash
flutter analyze lib/features/notes/widgets/notes_filter_sheet.dart
```

**Result:** No issues found (ran in 1.3s).

## Self-review

| Check | Result |
|-------|--------|
| Only specified file created/modified | ✅ |
| No create/add rows | ✅ |
| Confirm/clear return non-null `NotesFilterResult` | ✅ |
| Clear returns empty filter (`null` category, `[]` tags) | ✅ |
| X/barrier returns `null` | ✅ |
| Prefetch error handling matches picker pattern | ✅ |
| Chip styling matches editor picker | ✅ |
| Not wired into notes list screen (Task 3 scope) | ✅ |

## Concerns

None.

## Next steps (out of scope)

- Task 3: Wire filter icon/tab row on notes list screen to `showNotesFilterSheet` and connect confirm/clear to `NotesListNotifier.setCategoryTagFilter` / `clearCategoryTagFilter`.
