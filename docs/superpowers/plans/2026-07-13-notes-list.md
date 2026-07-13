# Notes List Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the notes list matching the mock (sticky「花森」header, expandable search, filter tabs, cards), wire `NotesService.listNotes` with pull-to-refresh / load-more, and add a three-tab `ShellRoute` (笔记 / 草稿 / 设置).

**Architecture:** `ShellRoute` owns the bottom nav. `NotesListScreen` → Riverpod `NotesListNotifier` → `NotesService.listNotes` (no Drift). Search submits via icon/keyboard only. 置顶 tab is empty-state only (no pin API).

**Tech Stack:** Flutter, Riverpod 3, go_router (`ShellRoute`), Dio, existing Freezed DTOs, Material + in-house `lib/ui/`, `tolyui_message`.

**Spec:** `docs/superpowers/specs/2026-07-13-notes-list-design.md`

**Working directory for all Flutter commands:** repository root (`d:\lbs\demo\sebhua-notes-app`).

## Global Constraints

- Work only on `master`; do not create branches or git worktrees.
- Accent via `Theme.of(context).colorScheme.primary` / `AppColors` — no per-page `#ed6f5c` hardcodes.
- No Drift / Repository this iteration.
- No automated tests; verify with `flutter analyze` + manual QA.
- Keep `/clipboard` route; remove clipboard from the bottom bar only.
- 置顶: empty state with pending-backend copy — no fake pin cards.
- Brand title on list header:「花森」(same as login).

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/core/constants/app_constants.dart` | Add `routeDrafts`; page size constant if useful |
| `lib/core/constants/ui_strings.dart` | Chinese list / tab / empty / error / nav copy |
| `lib/core/providers/core_providers.dart` | `notesServiceProvider` |
| `lib/core/router/app_router.dart` | `ShellRoute` + real screens; `/clipboard` outside shell |
| `lib/ui/shell/main_shell.dart` | Scaffold + 3-tab `CustomBottomNav` + `child` |
| `lib/features/notes/notes_list_state.dart` | Immutable list UI state |
| `lib/features/notes/notes_list_notifier.dart` | Load / search / refresh / loadMore / filter tab |
| `lib/features/notes/widgets/expandable_search_button.dart` | Search icon ↔ input animation |
| `lib/features/notes/widgets/notes_filter_tabs.dart` | 全部 / 置顶 / 最近 |
| `lib/features/notes/widgets/note_list_card.dart` | Mock-aligned card (optional left pin bar) |
| `lib/features/notes/notes_list_screen.dart` | Sticky header + list; no own bottom nav |
| `lib/features/notes/note_time_format.dart` | Relative Chinese timestamps |
| `lib/features/wechat/drafts_screen.dart` | Remove local bottom nav |
| `lib/features/settings/settings_screen.dart` | Remove local bottom nav |
| `lib/features/clipboard/clipboard_history_screen.dart` | Keep page; bottom nav optional (not in shell) — leave as-is or drop nav; do not add clipboard to shell |

---

### Task 1: Constants and Chinese copy

**Files:**
- Modify: `lib/core/constants/app_constants.dart`
- Modify: `lib/core/constants/ui_strings.dart`

**Interfaces:**
- Produces: `AppConstants.routeDrafts` (`'/drafts'`), `AppConstants.notesPageSize` (`20`); Chinese `UiStrings` keys listed below

- [ ] **Step 1: Extend `AppConstants`**

Add after `routeSettings`:

```dart
  /// WeChat drafts screen.
  static const String routeDrafts = '/drafts';

  /// Default page size for notes list.
  static const int notesPageSize = 20;
```

- [ ] **Step 2: Update navigation + notes list strings**

Change / add in `UiStrings` (Chinese to match mock + login):

```dart
  // --- Navigation ---
  static const String navNotes = '笔记';
  static const String navClipboard = '剪贴板';
  static const String navDrafts = '草稿';
  static const String navSettings = '设置';

  // --- Notes list screen ---
  static const String notesBrandTitle = '花森';
  static const String searchNotes = '搜索笔记';
  static const String searchNotesHint = '输入关键词';
  static const String notesFilterAll = '全部';
  static const String notesFilterPinned = '置顶';
  static const String notesFilterRecent = '最近';
  static const String noNotesFound = '还没有笔记';
  static const String noNotesHint = '点击右上角 + 创建第一条笔记';
  static const String noSearchResults = '没有找到相关笔记';
  static const String noSearchResultsHint = '试试其他关键词';
  static const String notesPinnedEmpty = '暂无置顶笔记';
  static const String notesPinnedEmptyHint = '置顶同步能力待后端支持';
  static const String notesLoadFailed = '加载失败，请重试';
  static const String notesRetry = '重试';
  static const String notesRefreshFailed = '刷新失败';
  static const String notesLoadMoreFailed = '加载更多失败，点击重试';
  static const String notesNoMore = '没有更多了';
  static const String notesUntitled = '无标题';
  static const String createNote = '新建笔记';
```

Keep existing English keys that other screens still use unless this change breaks them intentionally — prefer updating nav labels globally to Chinese as above.

- [ ] **Step 3: Analyze constants**

Run: `dart analyze lib/core/constants/`

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/core/constants/app_constants.dart lib/core/constants/ui_strings.dart
git commit -m "chore: add notes list routes and Chinese copy"
```

---

### Task 2: `notesServiceProvider` + list state/notifier

**Files:**
- Modify: `lib/core/providers/core_providers.dart`
- Create: `lib/features/notes/notes_list_state.dart`
- Create: `lib/features/notes/notes_list_notifier.dart`
- Create: `lib/features/notes/note_time_format.dart`

**Interfaces:**
- Consumes: `dioProvider`, `NotesService.listNotes`, `AppConstants.notesPageSize`, `UiStrings.*`
- Produces:
  - `notesServiceProvider` → `NotesService`
  - `enum NotesFilterTab { all, pinned, recent }`
  - `class NotesListState` with fields below
  - `notesListProvider` → `NotifierProvider<NotesListNotifier, NotesListState>`
  - `NotesListNotifier`: `Future<void> loadInitial()`, `Future<void> refresh()`, `Future<void> loadMore()`, `Future<void> search(String keyword)`, `Future<void> clearSearch()`, `Future<void> setFilter(NotesFilterTab tab)`, `Future<void> retry()`
  - `String formatNoteListTime(DateTime? updatedAt, DateTime? createdAt)`

- [ ] **Step 1: Add provider**

In `core_providers.dart`:

```dart
import '../../data/services/notes_service.dart';

final notesServiceProvider = Provider<NotesService>((ref) {
  return NotesService(ref.watch(dioProvider));
});
```

- [ ] **Step 2: Create `note_time_format.dart`**

```dart
String formatNoteListTime(DateTime? updatedAt, DateTime? createdAt) {
  final t = updatedAt ?? createdAt;
  if (t == null) return '';
  final now = DateTime.now();
  final local = t.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diffDays = today.difference(day).inDays;
  final hm =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  if (diffDays == 0) return '今天 $hm';
  if (diffDays == 1) return '昨天 $hm';
  if (now.year == local.year) {
    return '${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hm';
  }
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
```

- [ ] **Step 3: Create `notes_list_state.dart`**

```dart
import '../../data/models/note_dtos.dart';

enum NotesFilterTab { all, pinned, recent }

class NotesListState {
  const NotesListState({
    this.items = const [],
    this.page = 0,
    this.total = 0,
    this.keyword = '',
    this.filterTab = NotesFilterTab.all,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError = false,
  });

  final List<NoteDetailDto> items;
  final int page;
  final int total;
  final String keyword;
  final NotesFilterTab filterTab;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool loadMoreError;

  bool get hasMore => items.length < total;

  NotesListState copyWith({
    List<NoteDetailDto>? items,
    int? page,
    int? total,
    String? keyword,
    NotesFilterTab? filterTab,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool? loadMoreError,
  }) {
    return NotesListState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      keyword: keyword ?? this.keyword,
      filterTab: filterTab ?? this.filterTab,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }
}
```

- [ ] **Step 4: Create `notes_list_notifier.dart`**

Implement `NotesListNotifier extends Notifier<NotesListState>` (or `AsyncNotifier` pattern used elsewhere — prefer plain `Notifier` matching `AuthNotifier` style if that is simpler; otherwise `Notifier`):

Behavior (must match spec):

1. `build()` returns `const NotesListState()` then schedule `loadInitial()` (or call from screen `initState` via `ref.read(...).loadInitial()` — prefer explicit call from screen `initState` / first frame to avoid double-fetch).
2. `_fetchPage({required int page, required bool replace})`:
   - If `filterTab == pinned`: set `items=[]`, `total=0`, clear loading flags, return (no API).
   - Else call `notesService.listNotes(page: page, size: AppConstants.notesPageSize, keyword: keyword.isEmpty ? null : keyword)`.
   - On success (`isSuccess` && `data != null`): replace or append `items`; set `page`, `total`; clear errors.
   - On failure: set `errorMessage` for initial/replace; for load-more set `loadMoreError=true` and keep items; for refresh show is handled by UI via return `false` or set a short-lived flag — notifier should expose failure so UI can `$message.error(message: UiStrings.notesRefreshFailed)`.
3. Guard: ignore `loadMore` if `isLoadingMore || isInitialLoading || !hasMore`.
4. `setFilter`: update tab, reset list, reload (pinned → empty path).
5. `search` / `clearSearch`: update keyword, page 1 replace.

Use `ApiException` / `response.message` for error strings when available; fallback `UiStrings.notesLoadFailed`.

```dart
final notesListProvider =
    NotifierProvider<NotesListNotifier, NotesListState>(NotesListNotifier.new);
```

- [ ] **Step 5: Analyze**

Run: `dart analyze lib/core/providers/core_providers.dart lib/features/notes/`

Expected: no issues.

- [ ] **Step 6: Commit**

```bash
git add lib/core/providers/core_providers.dart lib/features/notes/notes_list_state.dart lib/features/notes/notes_list_notifier.dart lib/features/notes/note_time_format.dart
git commit -m "feat: add notes list notifier and NotesService provider"
```

---

### Task 3: Notes list UI widgets

**Files:**
- Create: `lib/features/notes/widgets/expandable_search_button.dart`
- Create: `lib/features/notes/widgets/notes_filter_tabs.dart`
- Create: `lib/features/notes/widgets/note_list_card.dart`

**Interfaces:**
- Consumes: `UiStrings`, `Theme`/`ColorScheme`, `formatNoteListTime`, `NoteDetailDto`
- Produces:
  - `ExpandableSearchButton({ required TextEditingController controller, required VoidCallback onSubmit, required VoidCallback onCollapsedClear })`
  - `NotesFilterTabs({ required NotesFilterTab value, required ValueChanged<NotesFilterTab> onChanged })`
  - `NoteListCard({ required NoteDetailDto note, required VoidCallback onTap, bool showPinChrome = false })`

- [ ] **Step 1: `ExpandableSearchButton`**

Collapsed: square rounded button with search icon (white/surface fill, soft border — match mock).

Expanded: `AnimatedContainer` / `AnimatedSize` grows horizontally into a field with:
- hint `UiStrings.searchNotesHint`
- `textInputAction: TextInputAction.search`
- `onSubmitted: (_) => onSubmit()`
- trailing search `IconButton` → `onSubmit()`
- optional clear + collapse (X) that clears text, collapses, calls `onCollapsedClear` if keyword was active

Autofocus when expanded. Use `colorScheme` only.

- [ ] **Step 2: `NotesFilterTabs`**

Row of three text tabs: 全部 / 置顶 / 最近. Active: `colorScheme.primary` + underline (`Container` height 2). Inactive: `onSurfaceVariant`. Tap calls `onChanged`.

- [ ] **Step 3: `NoteListCard`**

White/`surface` card, radius ~16, light shadow. Layout:
- Optional left coral vertical bar + pin icon when `showPinChrome`
- Title (`title` or `UiStrings.notesUntitled`), max 1 line
- Preview: strip simple newlines from `content`, max 2 lines
- Bottom row: `formatNoteListTime(updatedAt, createdAt)` left; if `mediaIds?.isNotEmpty` show small `Icons.image_outlined` (and/or `Icons.description_outlined`) right
- `InkWell` → `onTap`

Prefer a dedicated widget over stretching `CustomCard` if `CustomCard` cannot match left bar without messy forks.

- [ ] **Step 4: Analyze widgets**

Run: `dart analyze lib/features/notes/widgets/`

Expected: no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/notes/widgets/
git commit -m "feat: add notes list search, tabs, and card widgets"
```

---

### Task 4: Rebuild `NotesListScreen`

**Files:**
- Modify: `lib/features/notes/notes_list_screen.dart` (full rewrite)

**Interfaces:**
- Consumes: `notesListProvider`, widgets from Task 3, `go_router`, `tolyui_message`, `AppConstants`
- Produces: `NotesListScreen` with **no** `bottomNavigationBar` (shell owns it)

- [ ] **Step 1: Rewrite screen structure**

`ConsumerStatefulWidget`:

```
Scaffold(
  backgroundColor: colorScheme.surface, // canvas from theme
  body: SafeArea(
    child: Column(
      children: [
        _Header(...), // brand + ExpandableSearchButton + + button
        NotesFilterTabs(...),
        Expanded(child: _buildListBody()),
      ],
    ),
  ),
)
```

Header row:
- Left: `Text(UiStrings.notesBrandTitle, style: large bold)`
- Right: `ExpandableSearchButton` + coral square `IconButton`/`InkWell` with `Icons.add` → `context.push` note new route (`/note/${AppConstants.newNoteId}` or path that matches router)

On first frame: `ref.read(notesListProvider.notifier).loadInitial()` if `page == 0 && !isInitialLoading && items.isEmpty && errorMessage == null` (or always once via flag).

- [ ] **Step 2: List body**

- `isInitialLoading && items.isEmpty` → centered `CircularProgressIndicator`
- `errorMessage != null && items.isEmpty` → message + `TextButton` retry → `notifier.retry()`
- `filterTab == pinned` → empty pinned copy
- empty success → no notes / no search results copy based on `keyword`
- else: `RefreshIndicator(
    onRefresh: () async {
      final ok = await notifier.refresh();
      if (!ok) $message.error(message: UiStrings.notesRefreshFailed);
    },
    child: ListView.separated(
      controller: _scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: ...,
      // last item: loading more spinner / loadMoreError tappable / notesNoMore
    ),
  )`

Scroll listener: when near bottom (`pixels >= maxScrollExtent - 200`) call `loadMore()`.

Card tap: `context.push('/note/${note.id}')`.

`showPinChrome: false` always on API items (pinned tab empty).

- [ ] **Step 3: Analyze screen**

Run: `dart analyze lib/features/notes/notes_list_screen.dart`

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/features/notes/notes_list_screen.dart
git commit -m "feat: rebuild notes list screen with sticky header and pagination"
```

---

### Task 5: `MainShell` + `ShellRoute` + strip duplicate bottom navs

**Files:**
- Create: `lib/ui/shell/main_shell.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/wechat/drafts_screen.dart` — remove `bottomNavigationBar` and related `_onNavTap` / wide checks used only for nav
- Modify: `lib/features/settings/settings_screen.dart` — same
- Modify: `lib/features/notes/notes_list_screen.dart` — ensure no bottom nav (Task 4)
- Optional: `lib/features/clipboard/clipboard_history_screen.dart` — keep route; may keep its own nav for deep-link UX or remove nav and rely on back; **do not** add clipboard to shell

**Interfaces:**
- Consumes: `CustomBottomNav`, `AppConstants.routeHome|routeDrafts|routeSettings`, screen widgets
- Produces: `MainShell({ required Widget child })`; shell routes wired

- [ ] **Step 1: Create `MainShell`**

```dart
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith(AppConstants.routeSettings)) return 2;
    if (location.startsWith(AppConstants.routeDrafts)) return 1;
    return 0;
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
          : CustomBottomNav(
              currentIndex: index,
              items: const [
                CustomNavItem(
                  icon: Icons.note_outlined,
                  activeIcon: Icons.note,
                  label: UiStrings.navNotes,
                ),
                CustomNavItem(
                  icon: Icons.drafts_outlined,
                  activeIcon: Icons.drafts,
                  label: UiStrings.navDrafts,
                ),
                CustomNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: UiStrings.navSettings,
                ),
              ],
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go(AppConstants.routeHome);
                  case 1:
                    context.go(AppConstants.routeDrafts);
                  case 2:
                    context.go(AppConstants.routeSettings);
                }
              },
            ),
    );
  }
}
```

- [ ] **Step 2: Rewire `app_router.dart`**

Replace home/settings placeholders with:

```dart
ShellRoute(
  builder: (context, state, child) => MainShell(child: child),
  routes: [
    GoRoute(
      path: AppConstants.routeHome,
      name: 'home',
      builder: (context, state) => const NotesListScreen(),
    ),
    GoRoute(
      path: AppConstants.routeDrafts,
      name: 'drafts',
      builder: (context, state) => const DraftsScreen(),
    ),
    GoRoute(
      path: AppConstants.routeSettings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
),
```

Keep outside shell:
- auth + legal routes (unchanged)
- `routeNote` → prefer existing `NoteEditorScreen(noteId: id)` over `_PlaceholderScreen` (lightweight win; still out of scope for editor logic)
- `routeClipboard` → `ClipboardHistoryScreen` or placeholder; **not** in shell tabs

Remove obsolete home/settings `_PlaceholderScreen` usages that shell replaces.

Auth redirect: authenticated public routes → `AppConstants.routeHome` (unchanged).

- [ ] **Step 3: Strip bottom nav from drafts + settings**

Delete `bottomNavigationBar: ... CustomBottomNav ...` and `_onNavTap` from both screens. Keep app bars / body.

- [ ] **Step 4: Analyze router + shell + screens**

Run: `dart analyze lib/core/router/ lib/ui/shell/ lib/features/notes/ lib/features/wechat/drafts_screen.dart lib/features/settings/settings_screen.dart`

Expected: no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/shell/main_shell.dart lib/core/router/app_router.dart lib/features/wechat/drafts_screen.dart lib/features/settings/settings_screen.dart lib/features/notes/notes_list_screen.dart
git commit -m "feat: add ShellRoute main tabs without clipboard"
```

---

### Task 6: Full analyze + manual QA gate

**Files:** none required (docs optional: one-line AGENTS known-gap update only if you already touch AGENTS — skip unless asked)

- [ ] **Step 1: Project analyze**

Run: `flutter analyze`

Expected: no issues (or only pre-existing unrelated infos). Fix any new errors introduced by this plan.

- [ ] **Step 2: Manual QA checklist** (app: `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000`)

1. Login → `/` shows notes list (data or empty), header「花森」, three filter tabs, no clipboard in bottom bar.
2. Expand search → type → submit via keyboard and search icon → filtered results; clear/collapse restores list.
3. Pull to refresh; scroll to load more when enough notes exist.
4. 置顶 → empty pending copy; 全部/最近 reload list.
5.「+」→ new note route; card tap → detail/editor route.
6. Bottom tabs switch 笔记 / 草稿 / 设置; `/clipboard` still defined in router.
7. Theme primary remains coral; no hardcoded accent hex in new widgets.

- [ ] **Step 3: Final commit only if Step 1 left uncommitted fixes**

```bash
git status
# if dirty from analyze fixes:
git add -u
git commit -m "fix: address notes list analyze findings"
```

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Mock UI (花森, search expand, +, tabs, cards) | 3, 4 |
| Real `listNotes` + keyword/page/size | 2, 4 |
| Sticky header; list-only scroll | 4 |
| Pull refresh + load more | 2, 4 |
| ShellRoute 三 Tab; no clipboard in bar | 5 |
| Keep `/clipboard` | 5 |
| 置顶 empty / no pin API | 2, 4 |
| Manual QA only | 6 |
| No Drift | Global |

## Placeholder scan

No TBD/TODO placeholders; concrete paths, APIs, and copy included.

## Type consistency

- `NotesFilterTab` / `NotesListState` / `notesListProvider` names consistent across Tasks 2–4.
- Routes: `AppConstants.routeDrafts` = `'/drafts'` used by shell and router.
- Page size: `AppConstants.notesPageSize`.
