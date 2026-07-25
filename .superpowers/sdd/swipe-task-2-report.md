# Task 2 Report: NotesListScreen PageView + tab sync + KeepAlive pages

**Status:** DONE  
**Date:** 2026-07-25  
**Commits:** none (per instructions)

## Summary

Rewired `NotesListScreen` to use a three-page `PageView` (全部 / 置顶 / 最近) with bidirectional tab sync, per-tab KeepAlive list pages backed by `notesListProvider(tab)`, and shared search/filter via `notesListQueryProvider`.

## Files changed

| File | Action |
|------|--------|
| `lib/features/notes/notes_list_screen.dart` | **Modified** |

## Implementation details

### Shell (`_NotesListScreenState`)

- Added `PageController` (initial page 0 = `NotesFilterTab.all`) and `_activeTab` updated from `onPageChanged`.
- Header + `NotesFilterTabs` remain outside the pager.
- Tab tap → `animateToPage(index)`; tab highlight driven by `_activeTab` (not list state).
- Search submit/clear → `notesListQueryProvider.notifier.setKeyword` / `clearKeyword`.
- Category/tag sheet reads/writes `notesListQueryProvider` (`setCategoryTagFilter`).
- `hasActiveFilter` from `query.hasCategoryTagFilter`.

### Per-tab page (`_NotesListTabPage`)

- `ConsumerStatefulWidget` + `AutomaticKeepAliveClientMixin` (`wantKeepAlive: true`).
- Own `ScrollController` with load-more at 200px from bottom.
- Lazy `loadInitial` on first frame when `page == 0`, empty, not loading, no error.
- Pull-to-refresh / load-more / retry via `notesListProvider(tab).notifier`.
- Preserved empty/error/pinned-empty UX using `notesListQueryProvider.keyword` + tab.
- Preserved `NoteListCard`, `RefreshIndicator`, `_ListFooter` load-more footer.

### Tab order

`PageView` children: `NotesFilterTab.all` → `.pinned` → `.recent` (matches `NotesFilterTabs`).

## Verification

```text
dart analyze lib/features/notes/notes_list_screen.dart
Analyzing notes_list_screen.dart...
No issues found!
```

## Self-review

| Requirement | Met |
|-------------|-----|
| `PageController` + `_activeTab` from `onPageChanged` | Yes |
| Header/tabs outside pager; tap → `animateToPage` | Yes |
| `hasActiveFilter` from query provider | Yes |
| Search/filter on query provider | Yes |
| Three KeepAlive pages with own scroll + fetch | Yes |
| Lazy `loadInitial` per tab | Yes |
| Empty/error/pinned empty UX preserved | Yes |
| `NotesFilterTabs` API unchanged | Yes |
| No commit | Yes |
| No automated tests | Yes |

## Known temporary breaks (expected)

- `note_detail_screen.dart` / `note_editor_screen.dart` still call old `notesListProvider.notifier.refresh()` — Task 3 will switch to `refreshExistingNotesLists`.

## Concerns / notes for Task 3

- Query changes reload only tab providers that have been instantiated (`ref.exists` behavior from Task 1). Unvisited tabs load fresh on first swipe — acceptable.
- `PageView` may build adjacent pages eagerly; KeepAlive retains scroll/data once visited.
- Search text in `_searchController` is not synced from `notesListQueryProvider.keyword` on external changes (none today); fine for current UX.

## Fix

**Review findings addressed:**

1. **Important — lazy load:** Replaced `PageView(children: [...])` with `PageView.builder(itemCount: 3, ...)`. Pages are built on demand; `_NotesListTabPage` only runs `loadInitial` from its first `initState` post-frame callback, so never-visited tabs do not fetch until first built. `AutomaticKeepAliveClientMixin` still retains scroll/data once a page has been built.

2. **Minor — tab highlight on tap:** `_onTabChanged` now calls `setState(() => _activeTab = tab)` before `animateToPage`, so the tab underline updates immediately instead of waiting for the ~300ms animation / `onPageChanged`.

**Re-verify:**

```text
dart analyze lib/features/notes/notes_list_screen.dart
Analyzing notes_list_screen.dart...
No issues found!
```
