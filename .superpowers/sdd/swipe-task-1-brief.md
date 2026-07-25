# Task 1: Shared query provider + family NotesListNotifier

**Files:**
- Create: `lib/features/notes/notes_list_query.dart`
- Modify: `lib/features/notes/notes_list_state.dart`
- Modify: `lib/features/notes/notes_list_notifier.dart`

## Steps

- [ ] Add `NotesListQuery` (`keyword`, `categoryId`, `tagIds`) + `NotesListQueryNotifier` with `setKeyword`, `clearKeyword`, `setCategoryTagFilter` (no-op when unchanged). Export `notesListQueryProvider`.
- [ ] Remove duplicated query fields from `NotesListState` (`keyword`, `categoryId`, `tagIds`, `hasCategoryTagFilter`, and `filterTab` if unused). Keep loading/items/error/pagination fields.
- [ ] Convert `NotesListNotifier` to Riverpod 3 family: `NotifierProvider.family` / `FamilyNotifier<NotesListState, NotesFilterTab>`. `build(tab)` returns initial empty state; use family `tab` arg for `view` in `_fetchPage`.
- [ ] Remove `setFilter`. Remove `search` / `clearSearch` / `setCategoryTagFilter` / `clearCategoryTagFilter` from list notifier (moved to query).
- [ ] In `build(tab)`, watch `notesListQueryProvider` and reload page 1 when query changes after first load (avoid double-fetch with screen `loadInitial` on first build).
- [ ] `_fetchPage` reads keyword/category/tags from `ref.read(notesListQueryProvider)`.
- [ ] Add top-level helper `Future<void> refreshExistingNotesLists(Ref ref)` that for each `NotesFilterTab.values`, if `ref.exists(notesListProvider(tab))`, awaits `refresh()`.
- [ ] Screen/detail/editor may temporarily break until Tasks 2–3; that is OK for Task 1.
- [ ] Run `flutter analyze` (or dart analyze) on touched files; fix issues in Task 1 files.
- [ ] Do **not** commit.
- [ ] Write full report to `.superpowers/sdd/swipe-task-1-report.md`.

## Acceptance

Family provider keyed by tab; shared query provider; refresh helper; no `setFilter`.

## Global Constraints

- Work on `master` only; no feature branches / worktrees.
- Do not commit unless the user explicitly asks.
- Prefer manual QA; do not add automated tests unless required.
- Out of scope: shell bottom-nav swipe, drafts tabs, Drift/Repository.
