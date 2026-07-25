# Notes List Category / Tag Filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an icon-only category/tag filter on the notes home tab row that opens an independent bottom sheet and reloads `GET /notes` with `category` + `tags` (array).

**Architecture:** Keep editor `CategoryTagPickerSheet` untouched. Add `NotesFilterSheet` (select-only + 清除/确认). Persist selection on `NotesListState`; `NotesListNotifier` passes filters into every list fetch alongside existing `keyword` / `view` / `type=PUBLISHED`.

**Tech Stack:** Flutter, Riverpod, Dio, Material bottom sheet / chips, existing `CustomButton` / `AppColors` / `tolyui_message`

**Spec:** `docs/superpowers/specs/2026-07-23-notes-list-category-tag-filter-design.md`

**Working directory for all Flutter commands:** repo root (`d:\lbs\demo\sebhua-notes-app`)

## Global Constraints

- Implement on `master` only — no feature branches / worktrees unless the user explicitly asks.
- Do not add automated tests unless the user asks (manual QA for this phase).
- Do not modify `CategoryTagPickerSheet` or note editor save flows.
- Do not change drafts list filtering.
- API errors / prefetch failures: toast backend `message` via `tolyui_message`.
- Home filter uses query param `tags` (array); leave existing singular `tag` param unused by this feature.
- Commit only when the user explicitly asks (skip commit steps during execution unless told otherwise).

---

## File structure

| File | Responsibility |
|------|----------------|
| `lib/core/constants/ui_strings.dart` | Filter sheet title / confirm / clear strings |
| `lib/data/services/notes_service.dart` | `listNotes` accepts `List<String>? tags` |
| `lib/features/notes/notes_list_state.dart` | Hold `categoryId` + `tagIds`; badge getter |
| `lib/features/notes/notes_list_notifier.dart` | Apply/clear filters; pass into `_fetchPage` |
| `lib/features/notes/widgets/notes_filter_sheet.dart` | Prefetch + select-only sheet UI |
| `lib/features/notes/widgets/notes_filter_tabs.dart` | Tab row + trailing filter icon/badge |
| `lib/features/notes/notes_list_screen.dart` | Open sheet; wire confirm/clear to notifier |

---

### Task 1: API + list state/notifier filter plumbing

**Files:**
- Modify: `lib/core/constants/ui_strings.dart`
- Modify: `lib/data/services/notes_service.dart`
- Modify: `lib/features/notes/notes_list_state.dart`
- Modify: `lib/features/notes/notes_list_notifier.dart`

**Interfaces:**
- Consumes: existing `listNotes` callers (drafts etc.) — must remain binary-compatible
- Produces:
  - `NotesService.listNotes({ ..., List<String>? tags })`
  - `NotesListState.categoryId` (`String?`), `tagIds` (`List<String>`), `hasCategoryTagFilter` (`bool`)
  - `NotesListNotifier.setCategoryTagFilter({String? categoryId, List<String> tagIds = const []}) → Future<bool>`
  - `NotesListNotifier.clearCategoryTagFilter() → Future<bool>`

- [ ] **Step 1: Add UI strings**

Near the existing notes filter strings (`notesFilterAll` etc.), add:

```dart
static const String notesCategoryTagFilterTitle = '筛选';
static const String notesCategoryTagFilterConfirm = '确认';
static const String notesCategoryTagFilterClear = '清除';
```

Reuse `UiStrings.categoryTagPickerSelectCategory`, `categoryTagPickerSelectTags`, and `categoryTagPickerLoadFailed` inside the sheet (do not duplicate those).

- [ ] **Step 2: Extend `listNotes` with `tags`**

In `lib/data/services/notes_service.dart`, update the method signature and query map:

```dart
Future<ApiResponse<PaginatedNotesList>> listNotes({
  int? page,
  int? size,
  String? type,
  String? category,
  String? tag,
  List<String>? tags,
  String? keyword,
  String? mediaType,
  NotesListView? view,
}) async {
  final response = await _dio.get<Map<String, dynamic>>(
    '/notes',
    queryParameters: <String, dynamic>{
      'page': page,
      'size': size,
      'type': type,
      'category': category,
      'tag': tag,
      'tags': (tags == null || tags.isEmpty) ? null : tags,
      'keyword': keyword,
      'mediaType': mediaType,
      'view': switch (view) {
        NotesListView.pinned => 'pinned',
        NotesListView.recent => 'recent',
        null => null,
      },
    }..removeWhere((_, v) => v == null),
  );
  // existing fromJson body unchanged
}
```

Do not remove or rename `tag`.

- [ ] **Step 3: Extend `NotesListState`**

Replace `lib/features/notes/notes_list_state.dart` with:

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
    this.categoryId,
    this.tagIds = const [],
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError = false,
  });

  final List<NotesListItem> items;
  final int page;
  final int total;
  final String keyword;
  final NotesFilterTab filterTab;
  final String? categoryId;
  final List<String> tagIds;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool loadMoreError;

  bool get hasMore => items.length < total;

  bool get hasCategoryTagFilter =>
      categoryId != null || tagIds.isNotEmpty;

  NotesListState copyWith({
    List<NotesListItem>? items,
    int? page,
    int? total,
    String? keyword,
    NotesFilterTab? filterTab,
    String? categoryId,
    List<String>? tagIds,
    bool clearCategoryId = false,
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
      categoryId:
          clearCategoryId ? null : (categoryId ?? this.categoryId),
      tagIds: tagIds ?? this.tagIds,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }
}
```

- [ ] **Step 4: Wire notifier apply/clear + `_fetchPage`**

In `lib/features/notes/notes_list_notifier.dart`:

1. Add methods after `setFilter`:

```dart
  /// Apply category/tag filters and reload page 1.
  Future<bool> setCategoryTagFilter({
    String? categoryId,
    List<String> tagIds = const [],
  }) async {
    final nextTags = List<String>.from(tagIds);
    final sameCategory = state.categoryId == categoryId;
    final sameTags = _listEquals(state.tagIds, nextTags);
    if (sameCategory && sameTags) return true;

    final generation = ++_fetchGeneration;
    state = state.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
      tagIds: nextTags,
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

  Future<bool> clearCategoryTagFilter() => setCategoryTagFilter(
        categoryId: null,
        tagIds: const [],
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
```

2. In `_fetchPage`, pass filters into `listNotes`:

```dart
      final keyword = state.keyword.trim();
      final tags = state.tagIds;
      final response = await ref.read(notesServiceProvider).listNotes(
            page: page,
            size: AppConstants.notesPageSize,
            type: 'PUBLISHED',
            keyword: keyword.isEmpty ? null : keyword,
            category: state.categoryId,
            tags: tags.isEmpty ? null : tags,
            view: switch (state.filterTab) {
              NotesFilterTab.pinned => NotesListView.pinned,
              NotesFilterTab.recent => NotesListView.recent,
              NotesFilterTab.all => null,
            },
          );
```

- [ ] **Step 5: Verify analyze on touched files**

Run:

```bash
flutter analyze lib/core/constants/ui_strings.dart lib/data/services/notes_service.dart lib/features/notes/notes_list_state.dart lib/features/notes/notes_list_notifier.dart
```

Expected: No issues (or only pre-existing unrelated warnings).

- [ ] **Step 6: Commit (only if user asked to commit)**

```bash
git add lib/core/constants/ui_strings.dart lib/data/services/notes_service.dart lib/features/notes/notes_list_state.dart lib/features/notes/notes_list_notifier.dart
git commit -m "feat: plumb notes list category and tags filter into API"
```

---

### Task 2: Independent `NotesFilterSheet`

**Files:**
- Create: `lib/features/notes/widgets/notes_filter_sheet.dart`

**Interfaces:**
- Consumes: `categoriesServiceProvider`, `tagsServiceProvider`, `CategoryDto`, `TagResponseDto`, `UiStrings`, `AppColors`, `CustomButton`
- Produces:
  - `class NotesFilterResult { final String? categoryId; final List<String> tagIds; }`
  - `Future<NotesFilterResult?> showNotesFilterSheet(BuildContext context, {String? initialCategoryId, List<String> initialTagIds = const []})`
  - Confirm / Clear → non-null `NotesFilterResult` (clear / empty confirm → `categoryId: null`, `tagIds: []`)
  - X / barrier → `null`

- [ ] **Step 1: Create the sheet file**

Create `lib/features/notes/widgets/notes_filter_sheet.dart` with the full contents below. Match editor chip styling (compact ChoiceChip / FilterChip, `AppColors.categorySelected` / `AppColors.tagSelected`, black label text) but **omit** all create rows. Bottom row: secondary「清除」+ primary「确认」.

Use the same model imports as the editor picker currently uses (`category_dto.dart` / `tag_response_dto.dart`) unless the workspace has already migrated those call sites to `category_dtos.dart` — then match the migrated import.

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../../core/constants/ui_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../data/models/category_dto.dart';
import '../../../data/models/tag_response_dto.dart';
import '../../../ui/components/custom_button.dart';
import '../../../ui/theme/app_colors.dart';

/// Result from confirm/clear. Dismiss via X/barrier returns null instead.
class NotesFilterResult {
  const NotesFilterResult({
    this.categoryId,
    this.tagIds = const [],
  });

  final String? categoryId;
  final List<String> tagIds;
}

/// Prefetch categories/tags then show the select-only filter sheet.
Future<NotesFilterResult?> showNotesFilterSheet(
  BuildContext context, {
  String? initialCategoryId,
  List<String> initialTagIds = const [],
}) async {
  final container = ProviderScope.containerOf(context);
  final categoriesService = container.read(categoriesServiceProvider);
  final tagsService = container.read(tagsServiceProvider);

  List<CategoryDto> categories;
  List<TagResponseDto> tags;
  try {
    final categoriesResponse = await categoriesService.getCategoryTree();
    final tagsResponse = await tagsService.getTags();

    if (!categoriesResponse.isSuccess || !tagsResponse.isSuccess) {
      final message = categoriesResponse.isSuccess
          ? tagsResponse.message
          : categoriesResponse.message;
      $message.error(
        message: message.isNotEmpty
            ? message
            : UiStrings.categoryTagPickerLoadFailed,
      );
      return null;
    }
    categories = categoriesResponse.data ?? const <CategoryDto>[];
    tags = tagsResponse.data ?? const <TagResponseDto>[];
  } on DioException catch (error) {
    final apiError = error.error;
    $message.error(
      message: apiError is ApiException && apiError.message.isNotEmpty
          ? apiError.message
          : UiStrings.categoryTagPickerLoadFailed,
    );
    return null;
  } on Object {
    $message.error(message: UiStrings.categoryTagPickerLoadFailed);
    return null;
  }

  if (!context.mounted) return null;

  return showModalBottomSheet<NotesFilterResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => NotesFilterSheet(
      initialCategoryId: initialCategoryId,
      initialTagIds: initialTagIds,
      initialCategories: categories,
      initialTags: tags,
    ),
  );
}

class NotesFilterSheet extends StatefulWidget {
  const NotesFilterSheet({
    super.key,
    this.initialCategoryId,
    this.initialTagIds = const [],
    required this.initialCategories,
    required this.initialTags,
  });

  final String? initialCategoryId;
  final List<String> initialTagIds;
  final List<CategoryDto> initialCategories;
  final List<TagResponseDto> initialTags;

  @override
  State<NotesFilterSheet> createState() => _NotesFilterSheetState();
}

class _NotesFilterSheetState extends State<NotesFilterSheet> {
  late final List<CategoryDto> _categories;
  late final List<TagResponseDto> _tags;
  String? _selectedCategoryId;
  late List<String> _selectedTagIds;

  @override
  void initState() {
    super.initState();
    _categories = List<CategoryDto>.from(widget.initialCategories);
    _tags = List<TagResponseDto>.from(widget.initialTags);
    _selectedCategoryId = widget.initialCategoryId;
    _selectedTagIds = List<String>.from(widget.initialTagIds);
  }

  void _toggleCategory(String id) {
    setState(() {
      _selectedCategoryId = _selectedCategoryId == id ? null : id;
    });
  }

  void _toggleTag(String id) {
    setState(() {
      if (_selectedTagIds.contains(id)) {
        _selectedTagIds = List<String>.from(_selectedTagIds)..remove(id);
      } else {
        _selectedTagIds = List<String>.from(_selectedTagIds)..add(id);
      }
    });
  }

  void _popResult({String? categoryId, List<String> tagIds = const []}) {
    Navigator.of(context).pop(
      NotesFilterResult(categoryId: categoryId, tagIds: tagIds),
    );
  }

  void _onConfirm() {
    _popResult(
      categoryId: _selectedCategoryId,
      tagIds: List<String>.from(_selectedTagIds),
    );
  }

  void _onClear() {
    _popResult(categoryId: null, tagIds: const []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      UiStrings.notesCategoryTagFilterTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                children: [
                  Text(
                    UiStrings.categoryTagPickerSelectCategory,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in _categories)
                        ChoiceChip(
                          label: Text(
                            category.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (_) => _toggleCategory(category.id),
                          showCheckmark: false,
                          color: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.categorySelected;
                            }
                            return null;
                          }),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    UiStrings.categoryTagPickerSelectTags,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in _tags)
                        FilterChip(
                          label: Text(
                            tag.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          selected: _selectedTagIds.contains(tag.id),
                          onSelected: (_) => _toggleTag(tag.id),
                          showCheckmark: false,
                          color: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.tagSelected;
                            }
                            return null;
                          }),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: UiStrings.notesCategoryTagFilterClear,
                      variant: CustomButtonVariant.secondary,
                      expanded: true,
                      onPressed: _onClear,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: UiStrings.notesCategoryTagFilterConfirm,
                      expanded: true,
                      onPressed: _onConfirm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analyze**

Run:

```bash
flutter analyze lib/features/notes/widgets/notes_filter_sheet.dart
```

Expected: No issues. Fix import path if `CategoryDto` lives only in `category_dtos.dart`.

- [ ] **Step 3: Commit (only if user asked to commit)**

```bash
git add lib/features/notes/widgets/notes_filter_sheet.dart
git commit -m "feat: add notes list category/tag filter bottom sheet"
```

---

### Task 3: Tab-row filter icon + screen wiring

**Files:**
- Modify: `lib/features/notes/widgets/notes_filter_tabs.dart`
- Modify: `lib/features/notes/notes_list_screen.dart`

**Interfaces:**
- Consumes: `showNotesFilterSheet`, `NotesListNotifier.setCategoryTagFilter`, `state.hasCategoryTagFilter`, `state.categoryId`, `state.tagIds`
- Produces: Tab row trailing filter icon with badge; confirm/clear apply filters

- [ ] **Step 1: Extend `NotesFilterTabs`**

Replace `lib/features/notes/widgets/notes_filter_tabs.dart` with:

```dart
import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../notes_list_state.dart';

/// Text filter tabs for the notes list: 全部 / 置顶 / 最近, plus trailing filter icon.
class NotesFilterTabs extends StatelessWidget {
  const NotesFilterTabs({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onFilterTap,
    this.hasActiveFilter = false,
  });

  final NotesFilterTab value;
  final ValueChanged<NotesFilterTab> onChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilter;

  static const _tabs = <(NotesFilterTab, String)>[
    (NotesFilterTab.all, UiStrings.notesFilterAll),
    (NotesFilterTab.pinned, UiStrings.notesFilterPinned),
    (NotesFilterTab.recent, UiStrings.notesFilterRecent),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        for (final (tab, label) in _tabs) ...[
          if (tab != NotesFilterTab.all) const SizedBox(width: 20),
          _FilterTab(
            label: label,
            selected: value == tab,
            onTap: () => onChanged(tab),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
        const Spacer(),
        IconButton(
          onPressed: onFilterTap,
          tooltip: UiStrings.notesCategoryTagFilterTitle,
          visualDensity: VisualDensity.compact,
          icon: Badge(
            isLabelVisible: hasActiveFilter,
            smallSize: 8,
            child: Icon(
              Icons.filter_list,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              width: 28,
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Wire `NotesListScreen`**

In `lib/features/notes/notes_list_screen.dart`:

1. Import the sheet:

```dart
import 'widgets/notes_filter_sheet.dart';
```

2. Add handler on `_NotesListScreenState`:

```dart
  Future<void> _onCategoryTagFilterTap() async {
    final state = ref.read(notesListProvider);
    final result = await showNotesFilterSheet(
      context,
      initialCategoryId: state.categoryId,
      initialTagIds: state.tagIds,
    );
    if (!mounted || result == null) return;
    await ref.read(notesListProvider.notifier).setCategoryTagFilter(
          categoryId: result.categoryId,
          tagIds: result.tagIds,
        );
  }
```

3. Update the `NotesFilterTabs` call site:

```dart
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
              child: NotesFilterTabs(
                value: state.filterTab,
                onChanged: notifier.setFilter,
                onFilterTap: _onCategoryTagFilterTap,
                hasActiveFilter: state.hasCategoryTagFilter,
              ),
            ),
```

(Right padding 12 keeps the icon from hugging the edge; left stays 20.)

- [ ] **Step 3: Verify analyze**

Run:

```bash
flutter analyze lib/features/notes/widgets/notes_filter_tabs.dart lib/features/notes/notes_list_screen.dart lib/features/notes/widgets/notes_filter_sheet.dart
```

Expected: No issues.

- [ ] **Step 4: Commit (only if user asked to commit)**

```bash
git add lib/features/notes/widgets/notes_filter_tabs.dart lib/features/notes/notes_list_screen.dart
git commit -m "feat: wire notes list filter icon and sheet"
```

---

### Task 4: End-to-end verification

**Files:**
- None (verification only)

- [ ] **Step 1: Full analyze on notes feature paths**

Run:

```bash
flutter analyze lib/features/notes lib/data/services/notes_service.dart lib/core/constants/ui_strings.dart
```

Expected: No issues introduced by this work.

- [ ] **Step 2: Manual QA checklist**

With app running (authenticated):

1. Notes home tab row shows filter icon on the right (icon only).
2. Open sheet: category single-select, tag multi-select, no add rows; title「筛选」; 清除 + 确认.
3. Select category and/or tags → 确认 → list reloads; network shows `category` and/or `tags`; badge dot appears.
4. Tap 清除 → filters cleared, badge gone, list reloads without those params.
5. Open sheet, deselect all, 确认 → same as clear.
6. With filters active, dismiss via X → badge and list unchanged.
7. With filters active, switch 全部/置顶/最近 and search → requests still include category/`tags`.

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Icon-only filter on tab row right | Task 3 |
| Active badge/dot | Task 3 (`Badge` + `hasCategoryTagFilter`) |
| Independent sheet, editor picker untouched | Task 2 |
| No create/add | Task 2 |
| 清除 + empty 确认 both clear | Task 2 + Task 3 |
| X/barrier no change | Task 2 returns null; Task 3 ignores |
| `category` + `tags` array | Task 1 |
| Stack with keyword / view tabs | Task 1 `_fetchPage` |
| Prefetch error toast | Task 2 |
| Reuse empty-state copy | Task 3 (no new empty strings) |
| Manual QA only | Task 4 / Global Constraints |

## Type consistency (self-review)

- Result: `NotesFilterResult(categoryId, tagIds)` ↔ `setCategoryTagFilter(categoryId:, tagIds:)`
- State: `categoryId` / `tagIds` / `hasCategoryTagFilter`
- Service: `tags: List<String>?` (home); singular `tag` left intact
