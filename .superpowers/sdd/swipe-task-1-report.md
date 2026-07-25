# Task 1 Report: Shared query provider + family NotesListNotifier

**Status:** DONE  
**Date:** 2026-07-25  
**Commits:** none (per instructions)

## Summary

Implemented the data-layer split for Notes List Swipe Tabs: shared search/filter query state, per-tab family list notifiers, and a mutation refresh helper. Screen/detail/editor call sites are intentionally unchanged and will fail analyze until Tasks 2–3.

## Files changed

| File | Action |
|------|--------|
| `lib/features/notes/notes_list_query.dart` | **Created** |
| `lib/features/notes/notes_list_state.dart` | **Modified** |
| `lib/features/notes/notes_list_notifier.dart` | **Modified** |

## Implementation details

### `notes_list_query.dart`

- Added immutable `NotesListQuery` with `keyword`, `categoryId`, `tagIds`, `hasCategoryTagFilter`, `copyWith`, and value equality (for `ref.listen` diffing).
- Added `NotesListQueryNotifier` with no-op-when-unchanged:
  - `setKeyword(String)`
  - `clearKeyword()`
  - `setCategoryTagFilter({categoryId, tagIds})`
- Exported `notesListQueryProvider` as `NotifierProvider<NotesListQueryNotifier, NotesListQuery>`.

### `notes_list_state.dart`

Removed query ownership from list state:

- Dropped fields: `keyword`, `filterTab`, `categoryId`, `tagIds`, `hasCategoryTagFilter`.
- Kept pagination/loading/error fields: `items`, `page`, `total`, `isInitialLoading`, `isRefreshing`, `isLoadingMore`, `errorMessage`, `loadMoreError`, `hasMore`.
- Simplified `copyWith` accordingly.

### `notes_list_notifier.dart`

- Converted to Riverpod 3 family: `NotifierProvider.family<NotesListNotifier, NotesListState, NotesFilterTab>(NotesListNotifier.new)`.
- `NotesListNotifier(NotesFilterTab tab)` stores tab; `_fetchPage` uses `tab` for `view` (`pinned` / `recent` / null).
- Removed from list notifier: `setFilter`, `search`, `clearSearch`, `setCategoryTagFilter`, `clearCategoryTagFilter`.
- `build()`:
  - Watches + listens to `notesListQueryProvider`.
  - Returns `stateOrNull ?? const NotesListState()` so dependency rebuilds do not wipe cached tab data.
  - `ref.listen` skips the first emission (`previous == null`) to avoid double-fetch with screen `loadInitial`; subsequent query changes call `_reloadOnQueryChange()`.
- `_fetchPage` reads keyword/category/tags from `ref.read(notesListQueryProvider)`.
- Added top-level `refreshExistingNotesLists(Ref ref)` — iterates `NotesFilterTab.values`, and for each tab where `ref.exists(notesListProvider(tab))`, awaits `refresh()`.

## Verification

```text
dart analyze lib/features/notes/notes_list_query.dart lib/features/notes/notes_list_state.dart lib/features/notes/notes_list_notifier.dart
No issues found!
```

## Known temporary breaks (expected)

These files still reference the old non-family `notesListProvider` and removed notifier/state APIs; Task 2–3 will fix them:

- `lib/features/notes/notes_list_screen.dart` — `notesListProvider` without tab arg; `search` / `clearSearch` / `setFilter` / `setCategoryTagFilter`; state query fields.
- `lib/features/notes/note_detail_screen.dart` — `notesListProvider.notifier.refresh()`.
- `lib/features/notes/note_editor_screen.dart` — `notesListProvider.notifier.refresh()`.

## Self-review

| Requirement | Met |
|-------------|-----|
| Family provider keyed by `NotesFilterTab` | Yes |
| Shared `notesListQueryProvider` | Yes |
| `refreshExistingNotesLists` with `ref.exists` | Yes |
| No `setFilter` on list notifier | Yes |
| Query methods moved off list notifier | Yes |
| Avoid double-fetch on first load | Yes (`listen` skips initial emission) |
| No commit | Yes |
| No automated tests added | Yes |

## Notes for Task 2

- Screen should use `notesListProvider(tab)` per PageView page.
- Search/filter UI should call `notesListQueryProvider.notifier` methods.
- `hasActiveFilter` should read from `notesListQueryProvider` (`hasCategoryTagFilter` or keyword non-empty).

## Notes for Task 3

- Replace direct `notesListProvider.notifier.refresh()` with `refreshExistingNotesLists(ref)`.

## Fix

**Review finding:** `_reloadOnQueryChange` returned early when `isInitialLoading || isRefreshing`, dropping query updates during in-flight fetches.

**Change:** Removed that guard in `lib/features/notes/notes_list_notifier.dart`. Query changes now always increment `_fetchGeneration` and start a replace page-1 load; stale responses remain ignored via generation check in `_fetchPage`.

## Appendix (post-fix analyze)

```text
dart analyze lib/features/notes/notes_list_query.dart lib/features/notes/notes_list_state.dart lib/features/notes/notes_list_notifier.dart
Analyzing notes_list_query.dart, notes_list_state.dart, notes_list_notifier.dart...
No issues found!
```
