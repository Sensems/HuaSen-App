# Task 2: NotesListScreen PageView + tab sync + KeepAlive pages

**Files:**
- Modify: `lib/features/notes/notes_list_screen.dart`
- Touch if needed: `lib/features/notes/widgets/notes_filter_tabs.dart` (API should stay `value` / `onChanged`)

## Steps

- [ ] Add `PageController` (initial page 0 = all). Track `_activeTab` from `onPageChanged`.
- [ ] Keep header + `NotesFilterTabs` outside pager. Wire `onChanged` → `animateToPage(index)`. Highlight from `_activeTab`.
- [ ] `hasActiveFilter` from `notesListQueryProvider.hasCategoryTagFilter`.
- [ ] Search submit → `notesListQueryProvider.notifier.setKeyword`; clear → `clearKeyword`.
- [ ] Category/tag sheet → `setCategoryTagFilter` on query provider (read initials from query provider).
- [ ] Body: `PageView` with children for `NotesFilterTab.all`, `.pinned`, `.recent` in that order.
- [ ] Each page is a `ConsumerStatefulWidget` with `AutomaticKeepAliveClientMixin` (`wantKeepAlive: true`), own `ScrollController`, own pull-to-refresh / load-more calling `notesListProvider(tab)`.
- [ ] Lazy `loadInitial` on first appear if unloaded (page==0, empty, not loading, no error).
- [ ] Preserve empty/error/pinned empty UI using `notesListQueryProvider.keyword` + tab.
- [ ] Do **not** commit.
- [ ] Write report to `.superpowers/sdd/swipe-task-2-report.md`.

## Interfaces from Task 1 (use these)

```dart
notesListQueryProvider // NotesListQuery: keyword, categoryId, tagIds, hasCategoryTagFilter
notesListQueryProvider.notifier.setKeyword / clearKeyword / setCategoryTagFilter
notesListProvider(NotesFilterTab tab) // NotesListState without query fields
notesListProvider(tab).notifier.loadInitial / refresh / loadMore / retry
refreshExistingNotesLists(Ref ref) // not needed in this task
enum NotesFilterTab { all, pinned, recent }
```

## Acceptance

Swipe and tap switch tabs; return visit keeps scroll/data via KeepAlive + family state.

## Global Constraints

- master only; no commits; no automated tests; no shell/drafts/Drift work.
