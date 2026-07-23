# Notes List Category / Tag Filter

**Date:** 2026-07-23  
**Status:** Approved for planning  
**Scope:** Home notes list filter icon + independent filter bottom sheet + `GET /notes` category/`tags` query wiring

## Goal

On the notes home tab row (全部 / 置顶 / 最近), add an icon-only filter control that opens a bottom sheet for category (single) and tag (multi) selection. Confirm applies server-side filters via `category` and `tags` (array). No create/add affordances in this sheet.

## Background

- Tab row: `NotesFilterTabs` in `notes_list_screen.dart` (view filters only).
- Editor already has `CategoryTagPickerSheet` with create rows; this feature uses a **separate** sheet (Approach B) so editor UX stays untouched.
- `NotesService.listNotes` today exposes `category` and singular `tag`. Home filter will send `tags` as an array (backend contract per product); local OpenAPI may lag.
- List fetch already combines `type=PUBLISHED`, optional `keyword`, and `view` (pinned/recent). Category/tag filters stack with those.

## Decisions

| Topic | Choice |
|-------|--------|
| Approach | Independent `NotesFilterSheet` (not extend editor picker) |
| Category | Single select via `category` query param (omit when none) |
| Tags | Multi select via `tags` array query param (omit when empty) |
| Singular `tag` | Leave in service for other callers; home filter does not use it |
| Active indicator | Small badge/dot on filter icon when any category or tag is applied |
| Clear | Explicit「清除」button **and** confirm with empty selection both clear |
| Dismiss X / barrier | No state change, no refetch |
| Empty list copy | Reuse existing empty-state strings (no dedicated “no filter results” copy) |
| Tests | Manual QA only |

## Interaction

1. **Tab row:** Left = existing text tabs; right = filter icon only (`Icons.filter_list` or equivalent).
2. **Badge:** Shown when `categoryId != null` or `tagIds.isNotEmpty`.
3. **Open sheet:** Prefetch category tree + tags; on failure toast backend `message` (toly_ui) and do not open. Seed selection from current list filter state.
4. **Sheet UI:** Title「筛选」; close X; category ChoiceChips; tag FilterChips; same compact Chip styling / `AppColors.categorySelected` / `AppColors.tagSelected` as editor. **No** create input rows.
5. **确认:** Pop with selection → notifier applies filters → page 1 replace fetch.
6. **清除:** Clear local selection, pop as empty filter → notifier clears → page 1 replace fetch.
7. **空选 + 确认:** Same as clear (filters omitted from request; badge off).
8. **Combine:** Applied filters remain when switching 全部/置顶/最近 or searching; each refetch includes current category/`tags`.

## Architecture / data flow

```
NotesListScreen (tab row filter icon)
  → showNotesFilterSheet(initialCategoryId, initialTagIds)
       → CategoriesService.getCategoryTree + TagsService.getTags
       → NotesFilterSheet (confirm / clear / dismiss)
  → NotesListNotifier.setCategoryTagFilter / clearCategoryTagFilter
  → NotesService.listNotes(category, tags, keyword, view, type=PUBLISHED)
```

### State

`NotesListState` gains:

- `String? categoryId`
- `List<String> tagIds` (default empty)

`NotesListNotifier`:

- `setCategoryTagFilter({String? categoryId, List<String> tagIds})` — write state, clear list, fetch page 1
- `clearCategoryTagFilter()` — null/empty filters, fetch page 1
- `_fetchPage` passes `category` and `tags` when set

### API

`listNotes` adds optional `List<String>? tags`. Dio query serialization should send a repeated/array form the backend accepts (e.g. `tags=id1&tags=id2`). Empty/null omitted. `category` remains a single string ID.

### Result type

```dart
class NotesFilterResult {
  final String? categoryId;
  final List<String> tagIds;
}
```

Clear and empty-confirm both produce empty `categoryId` + empty `tagIds` (or invoke `clearCategoryTagFilter` directly).

## Files

**Add**

- `lib/features/notes/widgets/notes_filter_sheet.dart` — result type, `showNotesFilterSheet`, sheet UI

**Change**

- `lib/features/notes/widgets/notes_filter_tabs.dart` and/or `notes_list_screen.dart` — icon + badge on tab row
- `lib/features/notes/notes_list_state.dart`
- `lib/features/notes/notes_list_notifier.dart`
- `lib/data/services/notes_service.dart`
- `lib/core/constants/ui_strings.dart` — filter title, confirm, clear (and load-failed reuse if appropriate)

**Out of scope**

- `CategoryTagPickerSheet` / note editor
- Drafts list filters
- Drift / Repository
- Automated tests
- Updating mirrored OpenAPI files (optional follow-up if backend docs catch up)

## Error handling

- Prefetch failure: toast API `message` (fallback string if empty); sheet not shown.
- List fetch failure: existing notes list error / empty + retry paths unchanged.
- Refresh failure while filtered: keep existing refresh toast behavior.

## Testing / verification (manual)

1. Filter icon sits on the right of the tab row; icon-only.
2. Open sheet: chips mirror editor style; no add rows.
3. Select category and/or multiple tags → 确认 → request includes `category` and `tags`; list updates; badge appears.
4. 清除 or empty 确认 → filters cleared; badge gone; list reloads.
5. Dismiss via X / barrier → filters and badge unchanged.
6. With filters applied, switch view tabs and search still work; requests keep category/`tags`.
7. Prefetch error surfaces toast and does not open sheet.

## Non-goals

- Client-side-only filtering of already-loaded pages
- Persisting filter selection across app restarts
- Showing selected category/tag name chips on the list header (icon badge only)
