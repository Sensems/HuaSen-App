# Drafts List Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the 草稿箱 screen matching the mock (sticky title + chips, cards with 完善/删除), wire `NotesService.listNotes(type: 'draft')` with pull-to-refresh / load-more, and show draft `total` via Material `Badge.count` on the Shell drafts tab.

**Architecture:** Rebuild `DraftsScreen` → Riverpod `DraftsListNotifier` → `NotesService.listNotes` / `deleteNote` (no Drift). Independent `DraftsCountNotifier` supplies unfiltered `total` for `MainShell` `Badge.count` on the drafts `NavigationDestination`.

**Tech Stack:** Flutter, Riverpod 3, go_router (existing `ShellRoute`), Dio, existing Freezed DTOs, Material `Badge` / `NavigationBar`, in-house `lib/ui/`, `tolyui_message`.

**Spec:** `docs/superpowers/specs/2026-07-14-drafts-list-design.md`

**Working directory for all Flutter commands:** repository root (`d:\lbs\demo\sebhua-notes-app`).

## Global Constraints

- Work only on `master`; do not create branches or git worktrees.
- Accent via `Theme.of(context).colorScheme.primary` / `AppColors` — no per-page `#ed6f5c` hardcodes.
- No Drift / Repository this iteration.
- No automated tests; verify with `flutter analyze` + manual QA.
- Keep three-tab shell (笔记 / 草稿 / 设置); do not add clipboard to the bar.
- Always pass `type: 'draft'` for list + count; map chips to `mediaType` (`TEXT` / `IMAGE` / `VOICE`);「全部」omits `mediaType`.
- Known gap: OpenAPI enum may omit `TEXT` — still send it per spec; do not invent client-only filtering.
- Tab badge: Material `Badge.count` on drafts nav icons only; no custom `Stack`/`Positioned` red dots; omit `Badge` when count is 0 / unknown.
- Prefer backend `message` in toasts when present.

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/core/constants/ui_strings.dart` | Chinese drafts title / chips / empty / actions / errors |
| `lib/features/wechat/drafts_list_state.dart` | Immutable list UI state + `DraftsFilter` enum |
| `lib/features/wechat/drafts_list_notifier.dart` | Load / filter / refresh / loadMore / delete |
| `lib/features/wechat/drafts_count_provider.dart` | Unfiltered draft `total` for Shell badge |
| `lib/features/wechat/widgets/drafts_filter_chips.dart` | 全部 / 文本 / 图片 / 音频 chips |
| `lib/features/wechat/widgets/draft_list_card.dart` | Mock card: icon, title, time, body, 完善/删除 |
| `lib/features/wechat/drafts_screen.dart` | Sticky header + paginated list |
| `lib/ui/shell/main_shell.dart` | `ConsumerWidget` + `Badge.count` on drafts destination |
| Reuse | `notesServiceProvider`, `formatNoteListTime`, `AppConstants.notesPageSize`, `/drafts` route |

---

### Task 1: Chinese drafts copy

**Files:**
- Modify: `lib/core/constants/ui_strings.dart`

**Interfaces:**
- Produces: Chinese keys listed below (replace English drafts placeholders; keep `navDrafts = '草稿'`)

- [ ] **Step 1: Replace drafts section in `UiStrings`**

Replace the `// --- Drafts screen ---` block with:

```dart
  // --- Drafts screen ---
  static const String draftsTitle = '草稿箱';
  static const String draftsFilterAll = '全部';
  static const String draftsFilterText = '文本';
  static const String draftsFilterImage = '图片';
  static const String draftsFilterAudio = '音频';
  static const String noDrafts = '暂无草稿';
  static const String noDraftsHint = '微信同步的草稿会出现在这里';
  static const String draftsComplete = '完善';
  static const String draftsDelete = '删除';
  static const String draftsLoadFailed = '加载失败，请重试';
  static const String draftsRetry = '重试';
  static const String draftsRefreshFailed = '刷新失败';
  static const String draftsLoadMoreFailed = '加载更多失败，点击重试';
  static const String draftsNoMore = '没有更多了';
  static const String draftsDeleteFailed = '删除失败';
  static const String draftsMediaPlaceholder = '媒体';
  /// Kept temporarily for old drafts_screen until Task 5 rewrite.
  static const String wechatDrafts = draftsTitle;
  static const String convertToNote = draftsComplete;
  static const String draft = '草稿';
```

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/core/constants/ui_strings.dart`

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/ui_strings.dart
git commit -m "chore: add Chinese drafts list copy"
```

---

### Task 2: Drafts count provider

**Files:**
- Create: `lib/features/wechat/drafts_count_provider.dart`

**Interfaces:**
- Consumes: `notesServiceProvider`
- Produces:
  - `class DraftsCountNotifier extends AsyncNotifier<int>`
  - `Future<int> build()` / `Future<void> refresh()`
  - `final draftsCountProvider = AsyncNotifierProvider<DraftsCountNotifier, int>(...)`

Create count **before** the list notifier so list can call `refresh()` without circular stubs.

- [ ] **Step 1: Create `drafts_count_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';

class DraftsCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() => _fetchTotal();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTotal);
  }

  Future<int> _fetchTotal() async {
    final response = await ref.read(notesServiceProvider).listNotes(
          type: 'draft',
          page: 1,
          size: 1,
        );
    final data = response.data;
    if (response.isSuccess && data != null) {
      return data.total;
    }
    throw StateError(
      response.message.isNotEmpty ? response.message : 'drafts count failed',
    );
  }
}

final draftsCountProvider =
    AsyncNotifierProvider<DraftsCountNotifier, int>(DraftsCountNotifier.new);
```

`MainShell` must treat `AsyncLoading` / `AsyncError` / `0` as no badge; only `AsyncData` with `value > 0` shows `Badge.count`.

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/features/wechat/drafts_count_provider.dart`

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/wechat/drafts_count_provider.dart
git commit -m "feat: add drafts count provider for tab badge"
```

---

### Task 3: Drafts list state + notifier

**Files:**
- Create: `lib/features/wechat/drafts_list_state.dart`
- Create: `lib/features/wechat/drafts_list_notifier.dart`

**Interfaces:**
- Consumes: `notesServiceProvider`, `draftsCountProvider`, `AppConstants.notesPageSize`, `UiStrings`
- Produces:
  - `enum DraftsFilter { all, text, image, audio }`
  - `DraftsFilter.mediaType` → `String?` (`null` / `'TEXT'` / `'IMAGE'` / `'VOICE'`)
  - `DraftsListState` + `DraftsListNotifier`
  - Methods: `loadInitial()`, `Future<bool> refresh()`, `loadMore()`, `Future<bool> setFilter(DraftsFilter)`, `retry()`, `Future<bool> deleteDraft(String id)`
  - `draftsListProvider`

- [ ] **Step 1: Create `drafts_list_state.dart`**

```dart
import '../../data/models/note_dtos.dart';

enum DraftsFilter { all, text, image, audio }

extension DraftsFilterMediaType on DraftsFilter {
  /// Query value for `listNotes(mediaType:)`. Null means omit the param.
  String? get mediaType => switch (this) {
        DraftsFilter.all => null,
        DraftsFilter.text => 'TEXT',
        DraftsFilter.image => 'IMAGE',
        DraftsFilter.audio => 'VOICE',
      };
}

class DraftsListState {
  const DraftsListState({
    this.items = const [],
    this.page = 0,
    this.total = 0,
    this.filter = DraftsFilter.all,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError = false,
  });

  final List<NoteDetailDto> items;
  final int page;
  final int total;
  final DraftsFilter filter;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool loadMoreError;

  bool get hasMore => items.length < total;

  DraftsListState copyWith({
    List<NoteDetailDto>? items,
    int? page,
    int? total,
    DraftsFilter? filter,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool? loadMoreError,
  }) {
    return DraftsListState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      filter: filter ?? this.filter,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }
}
```

- [ ] **Step 2: Create `drafts_list_notifier.dart`**

Mirror `NotesListNotifier` (generation guard; refresh keeps items on failure; load-more sets `loadMoreError`). Always pass `type: 'draft'`.

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import 'drafts_count_provider.dart';
import 'drafts_list_state.dart';

class DraftsListNotifier extends Notifier<DraftsListState> {
  int _fetchGeneration = 0;

  @override
  DraftsListState build() => const DraftsListState();

  Future<void> loadInitial() async {
    if (state.isInitialLoading) return;
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      items: const [],
      page: 0,
      total: 0,
      isInitialLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      loadMoreError: false,
    );
    await _fetchPage(page: 1, replace: true, generation: generation);
  }

  Future<bool> refresh() async {
    if (state.isRefreshing || state.isInitialLoading) return true;
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      isRefreshing: true,
      isLoadingMore: false,
      loadMoreError: false,
    );
    final ok = await _fetchPage(
      page: 1,
      replace: true,
      isRefresh: true,
      generation: generation,
    );
    if (ok) {
      await ref.read(draftsCountProvider.notifier).refresh();
    }
    return ok;
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.isInitialLoading ||
        state.isRefreshing ||
        !state.hasMore) {
      return;
    }
    final generation = ++_fetchGeneration;
    state = state.copyWith(isLoadingMore: true, loadMoreError: false);
    await _fetchPage(
      page: state.page + 1,
      replace: false,
      generation: generation,
    );
  }

  Future<bool> setFilter(DraftsFilter filter) async {
    if (state.filter == filter) return true;
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      filter: filter,
      items: const [],
      page: 0,
      total: 0,
      isInitialLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      loadMoreError: false,
    );
    return _fetchPage(page: 1, replace: true, generation: generation);
  }

  Future<void> retry() => loadInitial();

  Future<bool> deleteDraft(String id) async {
    try {
      final response = await ref.read(notesServiceProvider).deleteNote(id);
      if (!response.isSuccess) {
        return false;
      }
      state = state.copyWith(
        items: state.items.where((n) => n.id != id).toList(),
        total: state.total > 0 ? state.total - 1 : 0,
      );
      await ref.read(draftsCountProvider.notifier).refresh();
      return true;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _fetchPage({
    required int page,
    required bool replace,
    required int generation,
    bool isRefresh = false,
  }) async {
    try {
      final response = await ref.read(notesServiceProvider).listNotes(
            page: page,
            size: AppConstants.notesPageSize,
            type: 'draft',
            mediaType: state.filter.mediaType,
          );
      if (generation != _fetchGeneration) return false;

      final data = response.data;
      if (response.isSuccess && data != null) {
        state = state.copyWith(
          items: replace ? data.items : [...state.items, ...data.items],
          page: data.page,
          total: data.total,
          isInitialLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          clearError: true,
          loadMoreError: false,
        );
        return true;
      }
      _handleFetchFailure(
        message: _messageOrFallback(response.message),
        replace: replace,
        isRefresh: isRefresh,
      );
      return false;
    } on DioException catch (e) {
      if (generation != _fetchGeneration) return false;
      _handleFetchFailure(
        message: _dioErrorMessage(e),
        replace: replace,
        isRefresh: isRefresh,
      );
      return false;
    } catch (_) {
      if (generation != _fetchGeneration) return false;
      _handleFetchFailure(
        message: UiStrings.draftsLoadFailed,
        replace: replace,
        isRefresh: isRefresh,
      );
      return false;
    }
  }

  void _handleFetchFailure({
    required String message,
    required bool replace,
    required bool isRefresh,
  }) {
    if (!replace) {
      state = state.copyWith(isLoadingMore: false, loadMoreError: true);
      return;
    }
    if (isRefresh) {
      state = state.copyWith(isRefreshing: false);
      return;
    }
    state = state.copyWith(
      items: const [],
      page: 0,
      total: 0,
      isInitialLoading: false,
      isRefreshing: false,
      isLoadingMore: false,
      errorMessage: message,
      loadMoreError: false,
    );
  }

  String _dioErrorMessage(DioException e) {
    final err = e.error;
    if (err is ApiException && err.message.isNotEmpty) {
      return err.message;
    }
    return UiStrings.draftsLoadFailed;
  }

  String _messageOrFallback(String message) {
    return message.isNotEmpty ? message : UiStrings.draftsLoadFailed;
  }
}

final draftsListProvider =
    NotifierProvider<DraftsListNotifier, DraftsListState>(
      DraftsListNotifier.new,
    );
```

- [ ] **Step 3: Analyze**

Run: `dart analyze lib/features/wechat/drafts_list_state.dart lib/features/wechat/drafts_list_notifier.dart`

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/features/wechat/drafts_list_state.dart lib/features/wechat/drafts_list_notifier.dart
git commit -m "feat: add drafts list notifier with type=draft filters"
```

---

### Task 4: Filter chips + draft card widgets

**Files:**
- Create: `lib/features/wechat/widgets/drafts_filter_chips.dart`
- Create: `lib/features/wechat/widgets/draft_list_card.dart`

**Interfaces:**
- Consumes: `DraftsFilter`, `UiStrings`, `NoteDetailDto`, `formatNoteListTime`
- Produces: `DraftsFilterChips`, `DraftListCard`

- [ ] **Step 1: Create `drafts_filter_chips.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../drafts_list_state.dart';

class DraftsFilterChips extends StatelessWidget {
  const DraftsFilterChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DraftsFilter value;
  final ValueChanged<DraftsFilter> onChanged;

  static const _chips = <(DraftsFilter, String)>[
    (DraftsFilter.all, UiStrings.draftsFilterAll),
    (DraftsFilter.text, UiStrings.draftsFilterText),
    (DraftsFilter.image, UiStrings.draftsFilterImage),
    (DraftsFilter.audio, UiStrings.draftsFilterAudio),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _Chip(
              label: _chips[i].$2,
              selected: value == _chips[i].$1,
              onTap: () => onChanged(_chips[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? colorScheme.primary : colorScheme.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create `draft_list_card.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../../../data/models/note_dtos.dart';
import '../../../ui/theme/app_colors.dart';
import '../../notes/note_time_format.dart';

Color _elevatedCardSurface(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.light
      ? AppColors.lightSurface
      : AppColors.darkSurface;
}

class DraftListCard extends StatelessWidget {
  const DraftListCard({
    super.key,
    required this.note,
    required this.onOpen,
    required this.onDelete,
  });

  final NoteDetailDto note;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  static String _previewText(String? content) {
    if (content == null || content.isEmpty) return '';
    return content.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = (note.title?.trim().isNotEmpty ?? false)
        ? note.title!.trim()
        : UiStrings.notesUntitled;
    final preview = _previewText(note.content);
    final timestamp = formatNoteListTime(note.updatedAt, note.createdAt);
    final hasMedia = note.mediaIds?.isNotEmpty ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: _elevatedCardSurface(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.mark_chat_unread,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timestamp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                if (hasMedia) ...[
                  const SizedBox(height: 10),
                  Container(
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      UiStrings.draftsMediaPlaceholder,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: onOpen,
                        child: const Text(UiStrings.draftsComplete),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDelete,
                        child: const Text(UiStrings.draftsDelete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Analyze**

Run: `dart analyze lib/features/wechat/widgets/`

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/features/wechat/widgets/drafts_filter_chips.dart lib/features/wechat/widgets/draft_list_card.dart
git commit -m "feat: add drafts filter chips and list card"
```

---

### Task 5: Rebuild `DraftsScreen`

**Files:**
- Modify: `lib/features/wechat/drafts_screen.dart` (full rewrite)
- Modify: `lib/core/constants/ui_strings.dart` (remove temp aliases if unused)

**Interfaces:**
- Consumes: `draftsListProvider`, `DraftsFilterChips`, `DraftListCard`, `UiStrings`, go_router, `tolyui_message`
- Produces: sticky header + list with refresh / load-more

- [ ] **Step 1: Replace `drafts_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import 'drafts_list_notifier.dart';
import 'drafts_list_state.dart';
import 'widgets/draft_list_card.dart';
import 'widgets/drafts_filter_chips.dart';

class DraftsScreen extends ConsumerStatefulWidget {
  const DraftsScreen({super.key});

  @override
  ConsumerState<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends ConsumerState<DraftsScreen> {
  final _scrollController = ScrollController();
  var _didRequestInitial = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadInitial());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _maybeLoadInitial() {
    if (!mounted || _didRequestInitial) return;
    final state = ref.read(draftsListProvider);
    if (state.page == 0 &&
        !state.isInitialLoading &&
        state.items.isEmpty &&
        state.errorMessage == null) {
      _didRequestInitial = true;
      ref.read(draftsListProvider.notifier).loadInitial();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(draftsListProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    final ok = await ref.read(draftsListProvider.notifier).refresh();
    if (!ok && mounted) {
      $message.error(message: UiStrings.draftsRefreshFailed);
    }
  }

  Future<void> _onDelete(String id) async {
    final ok = await ref.read(draftsListProvider.notifier).deleteDraft(id);
    if (!ok && mounted) {
      $message.error(message: UiStrings.draftsDeleteFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final state = ref.watch(draftsListProvider);
    final notifier = ref.read(draftsListProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                UiStrings.draftsTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: DraftsFilterChips(
                value: state.filter,
                onChanged: notifier.setFilter,
              ),
            ),
            Expanded(child: _buildListBody(state, notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildListBody(DraftsListState state, DraftsListNotifier notifier) {
    if (state.isInitialLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return _EmptyMessage(
        title: state.errorMessage!,
        actionLabel: UiStrings.draftsRetry,
        onAction: notifier.retry,
      );
    }

    if (state.items.isEmpty) {
      return const _EmptyMessage(
        title: UiStrings.noDrafts,
        subtitle: UiStrings.noDraftsHint,
      );
    }

    final itemCount = state.items.length + 1;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: itemCount,
        separatorBuilder: (_, index) {
          if (index >= state.items.length - 1) {
            return const SizedBox.shrink();
          }
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return _ListFooter(
              isLoadingMore: state.isLoadingMore,
              loadMoreError: state.loadMoreError,
              hasMore: state.hasMore,
              onRetryLoadMore: notifier.loadMore,
            );
          }
          final note = state.items[index];
          return DraftListCard(
            note: note,
            onOpen: () => context.push('/note/${note.id}'),
            onDelete: () => _onDelete(note.id),
          );
        },
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({
    required this.isLoadingMore,
    required this.loadMoreError,
    required this.hasMore,
    required this.onRetryLoadMore,
  });

  final bool isLoadingMore;
  final bool loadMoreError;
  final bool hasMore;
  final VoidCallback onRetryLoadMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (loadMoreError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: TextButton(
            onPressed: onRetryLoadMore,
            child: const Text(UiStrings.draftsLoadMoreFailed),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            UiStrings.draftsNoMore,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 8);
  }
}
```

- [ ] **Step 2: Remove unused aliases**

If nothing references `wechatDrafts` / `convertToNote`, remove those two lines from `UiStrings`.

- [ ] **Step 3: Analyze**

Run: `dart analyze lib/features/wechat/ lib/core/constants/ui_strings.dart`

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/features/wechat/drafts_screen.dart lib/core/constants/ui_strings.dart
git commit -m "feat: rebuild drafts screen with sticky header and API list"
```

---

### Task 6: Shell `Badge.count` on drafts tab

**Files:**
- Modify: `lib/ui/shell/main_shell.dart`

**Interfaces:**
- Consumes: `draftsCountProvider`
- Produces: `MainShell` as `ConsumerWidget`; drafts icons use `Badge.count` when count > 0

- [ ] **Step 1: Convert shell and wire badge**

Replace `main_shell.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../features/wechat/drafts_count_provider.dart';

/// App shell with bottom tabs: notes / drafts / settings.
///
/// Clipboard stays a deep-link-only route and is not shown here.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith(AppConstants.routeSettings)) return 2;
    if (location.startsWith(AppConstants.routeDrafts)) return 1;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go(AppConstants.routeHome);
      case 1:
        context.go(AppConstants.routeDrafts);
      case 2:
        context.go(AppConstants.routeSettings);
    }
  }

  Widget _draftsIcon(IconData iconData, AsyncValue<int> countAsync) {
    final count = countAsync.asData?.value;
    if (count == null || count <= 0) {
      return Icon(iconData);
    }
    return Badge.count(
      count: count,
      child: Icon(iconData),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexForLocation(location);
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final draftsCount = ref.watch(draftsCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => _onDestinationSelected(context, i),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.note_outlined),
                  selectedIcon: Icon(Icons.note),
                  label: UiStrings.navNotes,
                ),
                NavigationDestination(
                  icon: _draftsIcon(Icons.drafts_outlined, draftsCount),
                  selectedIcon: _draftsIcon(Icons.drafts, draftsCount),
                  label: UiStrings.navDrafts,
                ),
                const NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: UiStrings.navSettings,
                ),
              ],
            ),
    );
  }
}
```

If `Badge.count` supports `maxCount` on this SDK, pass e.g. `999`.

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/ui/shell/main_shell.dart lib/features/wechat/`

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/ui/shell/main_shell.dart
git commit -m "feat: show drafts total with Badge.count on NavigationBar"
```

---

### Task 7: Full analyze + manual QA

**Files:** none (verification only)

- [ ] **Step 1: Analyze app**

Run: `flutter analyze`

Expected: no new issues in touched code.

- [ ] **Step 2: Manual QA checklist**

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

1. Login → 草稿: sticky「草稿箱」+ chips 全部/文本/图片/音频; only list scrolls.
2. Requests use `type=draft`; chips send `mediaType=TEXT|IMAGE|VOICE`; 全部 omits `mediaType`.
3. Pull-to-refresh and load-more work; empty/error/retry work.
4. Card uses `mark_chat_unread`; 完善 / card tap → `/note/:id`; delete removes row and decreases badge (no confirm).
5. Shell drafts icon uses Material `Badge.count` for unfiltered `total`; hidden at 0; unaffected by chips.
6. Bottom bar remains 笔记 / 草稿 / 设置.

- [ ] **Step 3: Fix-only commit if QA found bugs**

Do not create an empty commit.

---

## Spec coverage self-check

| Spec requirement | Task |
|------------------|------|
| Sticky 草稿箱 + chips; list-only scroll | 5 |
| Chips 全部/文本/图片/音频 | 1, 4, 5 |
| `type=draft` + mediaType mapping | 3 |
| Pull-to-refresh / load-more | 3, 5 |
| Card icon / title / content / time | 4 |
| Generic media placeholder | 4 |
| 完善 + card tap → editor | 4, 5 |
| Delete API + badge refresh | 2, 3, 5 |
| Unfiltered total + `Badge.count` | 2, 6 |
| Three-tab shell | 6 |
| Manual QA only | 7 |

## Consistency self-check

- `draftsCountProvider` / `DraftsCountNotifier.refresh` names match across Tasks 2–6.
- `DraftsFilter.mediaType` values match API mapping in the spec.
- Task 2 (count) precedes Task 3 (list) so imports resolve cleanly.
