# Notes List Swipe Tabs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Home notes list supports finger-following swipe between 全部 / 置顶 / 最近, keeping each tab’s list data and scroll position.

**Architecture:** Fixed header + `NotesFilterTabs`; body is a 3-page `PageView`. `notesListProvider` becomes a family keyed by `NotesFilterTab`. Shared `notesListQueryProvider` holds keyword / categoryId / tagIds; each tab notifier watches it and reloads on change. Tab switches are UI-only (PageController).

**Tech Stack:** Flutter, Riverpod 3 (`NotifierProvider.family` / `FamilyNotifier`), existing `NotesService.listNotes`.

## Global Constraints

- Work on `master` only; no feature branches / worktrees.
- Do not commit unless the user explicitly asks.
- Prefer manual QA; do not add automated tests unless the task requires them.
- UI strings via `UiStrings`; API errors via backend `message` + tolyui where applicable.
- Keep existing empty/error/pinned copy and list card UX per page.
- Never-visited tabs stay lazy; mutation refresh uses `ref.exists` over all tabs.
- Out of scope: shell bottom-nav swipe, drafts tabs, Drift/Repository.

---

### Task 1: Shared query provider + family NotesListNotifier

**Files:**
- Create: `lib/features/notes/notes_list_query.dart`
- Modify: `lib/features/notes/notes_list_state.dart`
- Modify: `lib/features/notes/notes_list_notifier.dart`

- [ ] Add `NotesListQuery` (`keyword`, `categoryId`, `tagIds`) + `NotesListQueryNotifier` with `setKeyword`, `clearKeyword`, `setCategoryTagFilter` (no-op when unchanged). Export `notesListQueryProvider`.
- [ ] Remove query fields from list fetch ownership: `NotesListState` may drop `keyword` / `categoryId` / `tagIds` / `hasCategoryTagFilter` / `filterTab` if unused, **or** keep `filterTab` only as documentation via family arg — prefer removing duplicated query fields from `NotesListState` so query lives only in `notesListQueryProvider`. Keep loading/items/error fields.
- [ ] Convert `NotesListNotifier` to Riverpod 3 family: `NotifierProvider.family` / `FamilyNotifier<NotesListState, NotesFilterTab>`. `build(tab)` returns initial empty state; store/use `tab` for `view` in `_fetchPage`.
- [ ] Remove `setFilter`. Remove `search` / `clearSearch` / `setCategoryTagFilter` / `clearCategoryTagFilter` from list notifier (moved to query).
- [ ] In `build(tab)`, `ref.watch(notesListQueryProvider)` and reload page 1 when query changes after first load (skip the initial build emission to avoid double-fetch with screen `loadInitial`, or coordinate so only one load path runs).
- [ ] `_fetchPage` reads keyword/category/tags from `ref.read(notesListQueryProvider)`.
- [ ] Add top-level helper `Future<void> refreshExistingNotesLists(Ref ref)` that for each `NotesFilterTab.values`, if `ref.exists(notesListProvider(tab))`, awaits `refresh()`.
- [ ] Ensure `notes_list_screen.dart` / detail / editor still compile enough for Task 2–3 (temporary breaks OK only if Task 2 immediately follows; prefer keeping a thin compatibility compile by updating call sites minimally in Task 1 only if needed — **Task 1 may leave screen temporarily broken**; Task 2 fixes screen).
- [ ] Run `dart analyze` on touched notifier/query/state files (or `flutter analyze` if easier).
- [ ] Do **not** commit.
- [ ] Write report to `.superpowers/sdd/swipe-task-1-report.md`.

**Acceptance:** Family provider keyed by tab; shared query provider; refresh helper; no `setFilter`.

---

### Task 2: NotesListScreen PageView + tab sync + KeepAlive pages

**Files:**
- Modify: `lib/features/notes/notes_list_screen.dart`
- Touch if needed: `lib/features/notes/widgets/notes_filter_tabs.dart` (API should stay `value` / `onChanged`)

- [ ] Add `PageController` (initial page 0 = all). Track `_activeTab` from `onPageChanged`.
- [ ] Keep header + `NotesFilterTabs` outside pager. Wire `onChanged` → `animateToPage(index)`. Highlight from `_activeTab`.
- [ ] `hasActiveFilter` from `notesListQueryProvider`.
- [ ] Search submit → `notesListQueryProvider.notifier.setKeyword`; clear → `clearKeyword`.
- [ ] Category/tag sheet → `setCategoryTagFilter` on query provider.
- [ ] Body: `PageView` with children for `NotesFilterTab.all`, `.pinned`, `.recent` in that order.
- [ ] Each page is a `ConsumerStatefulWidget` with `AutomaticKeepAliveClientMixin` (`wantKeepAlive: true`), own `ScrollController`, own pull-to-refresh / load-more calling `notesListProvider(tab)`.
- [ ] Lazy `loadInitial` on first appear if unloaded (page==0, empty, not loading, no error).
- [ ] Preserve empty/error/pinned empty UI using query keyword + tab.
- [ ] Do **not** commit.
- [ ] Write report to `.superpowers/sdd/swipe-task-2-report.md`.

**Acceptance:** Swipe and tap switch tabs; return visit keeps scroll/data via KeepAlive + family state.

---

### Task 3: Detail/editor refresh call sites + analyze

**Files:**
- Modify: `lib/features/notes/note_detail_screen.dart`
- Modify: `lib/features/notes/note_editor_screen.dart`

- [ ] Replace `ref.read(notesListProvider.notifier).refresh()` with `refreshExistingNotesLists(ref)`.
- [ ] Grep for any remaining non-family `notesListProvider` usages and fix.
- [ ] Run `flutter analyze` at repo root; fix any issues introduced.
- [ ] Do **not** commit.
- [ ] Write report to `.superpowers/sdd/swipe-task-3-report.md`.

**Acceptance:** Analyze clean for this feature; mutation refresh hits existing tab instances only.

---

### Task 4: Design spec document

**Files:**
- Create: `docs/superpowers/specs/2026-07-25-notes-list-swipe-tabs-design.md`
- Plan already at: `docs/superpowers/plans/2026-07-25-notes-list-swipe-tabs.md`

- [ ] Write a concise design spec matching the approved architecture (PageView + family + shared query + refreshExisting helper + behaviors).
- [ ] Do **not** commit.
- [ ] Write report to `.superpowers/sdd/swipe-task-4-report.md`.

**Acceptance:** Spec file present and consistent with implementation.
