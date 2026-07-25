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
