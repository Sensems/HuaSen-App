# Final review package — Notes List Swipe Tabs (working tree vs HEAD 9190586)

## Status
 M lib/features/notes/note_detail_screen.dart
 M lib/features/notes/note_editor_screen.dart
 M lib/features/notes/notes_list_notifier.dart
 M lib/features/notes/notes_list_screen.dart
 M lib/features/notes/notes_list_state.dart
 M lib/features/notes/widgets/notes_filter_tabs.dart
?? docs/superpowers/plans/2026-07-25-notes-list-swipe-tabs.md
?? docs/superpowers/specs/2026-07-25-notes-list-swipe-tabs-design.md
?? lib/features/notes/image_preview_screen.dart
?? lib/features/notes/note_attachment_actions.dart
?? lib/features/notes/notes_list_query.dart
?? lib/features/notes/widgets/category_tag_picker_sheet.dart
?? lib/features/notes/widgets/note_attachment_card.dart
?? lib/features/notes/widgets/notes_filter_sheet.dart

## Diff stat (feature files)

 lib/features/notes/note_detail_screen.dart        | 187 ++++++-----
 lib/features/notes/note_editor_screen.dart        | 367 +++++++++++++++++-----
 lib/features/notes/notes_list_notifier.dart       |  84 +++--
 lib/features/notes/notes_list_screen.dart         | 171 +++++++---
 lib/features/notes/notes_list_state.dart          |   8 -
 lib/features/notes/widgets/notes_filter_tabs.dart |  20 +-
 6 files changed, 586 insertions(+), 251 deletions(-)

## Untracked new files


### notes_list_query.dart (new) — see file on disk
### design + plan — see docs/superpowers/

## Key implementation excerpts

diff --git a/lib/features/notes/notes_list_notifier.dart b/lib/features/notes/notes_list_notifier.dart
index e213757..856315b 100644
--- a/lib/features/notes/notes_list_notifier.dart
+++ b/lib/features/notes/notes_list_notifier.dart
@@ -1,21 +1,38 @@
+import 'dart:async';
+
 import 'package:dio/dio.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
 
 import '../../core/constants/app_constants.dart';
 import '../../core/constants/ui_strings.dart';
 import '../../core/network/api_exception.dart';
 import '../../core/providers/core_providers.dart';
 import '../../data/models/note_dtos.dart';
+import 'notes_list_query.dart';
 import 'notes_list_state.dart';
 
 class NotesListNotifier extends Notifier<NotesListState> {
+  NotesListNotifier(this.tab);
+
+  final NotesFilterTab tab;
+
   /// Bumped on every fetch so stale responses cannot overwrite newer state.
   int _fetchGeneration = 0;
 
   @override
-  NotesListState build() => const NotesListState();
+  NotesListState build() {
+    ref
+      ..watch(notesListQueryProvider)
+      ..listen(notesListQueryProvider, (previous, next) {
+        if (previous == null || previous == next) return;
+        if (stateOrNull == null) return;
+        unawaited(_reloadOnQueryChange());
+      });
+
+    return stateOrNull ?? const NotesListState();
+  }
 
   /// Loads page 1. Call from the screen on first frame (not from [build]).
   Future<void> loadInitial() async {
     if (state.isInitialLoading) return;
     final generation = ++_fetchGeneration;
@@ -59,79 +76,45 @@ class NotesListNotifier extends Notifier<NotesListState> {
     final generation = ++_fetchGeneration;
     state = state.copyWith(isLoadingMore: true, loadMoreError: false);
     await _fetchPage(page: state.page + 1, replace: false, generation: generation);
   }
 
-  /// Search page 1 replace. Returns `false` on failure (empty list + error).
-  Future<bool> search(String keyword) async {
-    final generation = ++_fetchGeneration;
-    state = state.copyWith(
-      keyword: keyword.trim(),
-      items: const [],
-      page: 0,
-      total: 0,
-      isInitialLoading: true,
-      isRefreshing: false,
-      isLoadingMore: false,
-      clearError: true,
-      loadMoreError: false,
-    );
-    return _fetchPage(page: 1, replace: true, generation: generation);
-  }
-
-  /// Clears keyword and reloads page 1. Returns `false` on failure.
-  Future<bool> clearSearch() async {
-    if (state.keyword.isEmpty) return true;
-    final generation = ++_fetchGeneration;
-    state = state.copyWith(
-      keyword: '',
-      items: const [],
-      page: 0,
-      total: 0,
-      isInitialLoading: true,
-      isRefreshing: false,
-      isLoadingMore: false,
-      clearError: true,
-      loadMoreError: false,
-    );
-    return _fetchPage(page: 1, replace: true, generation: generation);
-  }
+  Future<void> retry() => loadInitial();
 
-  /// Switch filter tab. Returns `false` on failure (empty list + error).
-  Future<bool> setFilter(NotesFilterTab tab) async {
-    if (state.filterTab == tab) return true;
+  Future<void> _reloadOnQueryChange() async {
     final generation = ++_fetchGeneration;
     state = state.copyWith(
-      filterTab: tab,
       items: const [],
       page: 0,
       total: 0,
       isInitialLoading: true,
       isRefreshing: false,
       isLoadingMore: false,
       clearError: true,
       loadMoreError: false,
     );
-    return _fetchPage(page: 1, replace: true, generation: generation);
+    await _fetchPage(page: 1, replace: true, generation: generation);
   }
 
-  Future<void> retry() => loadInitial();
-
   Future<bool> _fetchPage({
     required int page,
     required bool replace,
     required int generation,
     bool isRefresh = false,
   }) async {
     try {
-      final keyword = state.keyword.trim();
+      final query = ref.read(notesListQueryProvider);
+      final keyword = query.keyword.trim();
+      final tags = query.tagIds;
       final response = await ref.read(notesServiceProvider).listNotes(
             page: page,
             size: AppConstants.notesPageSize,
             type: 'PUBLISHED',
             keyword: keyword.isEmpty ? null : keyword,
-            view: switch (state.filterTab) {
+            category: query.categoryId,
+            tags: tags.isEmpty ? null : tags,
+            view: switch (tab) {
               NotesFilterTab.pinned => NotesListView.pinned,
               NotesFilterTab.recent => NotesListView.recent,
               NotesFilterTab.all => null,
             },
           );
@@ -215,6 +198,17 @@ class NotesListNotifier extends Notifier<NotesListState> {
     return message.isNotEmpty ? message : UiStrings.notesLoadFailed;
   }
 }
 
 final notesListProvider =
-    NotifierProvider<NotesListNotifier, NotesListState>(NotesListNotifier.new);
+    NotifierProvider.family<NotesListNotifier, NotesListState, NotesFilterTab>(
+  NotesListNotifier.new,
+);
+
+/// Refreshes only tab list instances that have been created (visited).
+Future<void> refreshExistingNotesLists(WidgetRef ref) async {
+  for (final tab in NotesFilterTab.values) {
+    if (ref.exists(notesListProvider(tab))) {
+      await ref.read(notesListProvider(tab).notifier).refresh();
+    }
+  }
+}
diff --git a/lib/features/notes/notes_list_screen.dart b/lib/features/notes/notes_list_screen.dart
index 082d311..89bf5fe 100644
--- a/lib/features/notes/notes_list_screen.dart
+++ b/lib/features/notes/notes_list_screen.dart
@@ -4,13 +4,15 @@ import 'package:go_router/go_router.dart';
 import 'package:tolyui_message/tolyui_message.dart';
 
 import '../../core/constants/app_constants.dart';
 import '../../core/constants/ui_strings.dart';
 import 'notes_list_notifier.dart';
+import 'notes_list_query.dart';
 import 'notes_list_state.dart';
 import 'widgets/expandable_search_button.dart';
 import 'widgets/note_list_card.dart';
+import 'widgets/notes_filter_sheet.dart';
 import 'widgets/notes_filter_tabs.dart';
 
 /// Notes list with sticky brand header, filter tabs, and paginated API data.
 ///
 /// Bottom navigation is owned by the shell (Task 5) 鈥?this screen has none.
@@ -20,70 +22,80 @@ class NotesListScreen extends ConsumerStatefulWidget {
   @override
   ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
 }
 
 class _NotesListScreenState extends ConsumerState<NotesListScreen> {
+  static const _tabOrder = <NotesFilterTab>[
+    NotesFilterTab.all,
+    NotesFilterTab.pinned,
+    NotesFilterTab.recent,
+  ];
+
   final _searchController = TextEditingController();
-  final _scrollController = ScrollController();
-  var _didRequestInitial = false;
+  late final PageController _pageController;
+  var _activeTab = NotesFilterTab.all;
 
   @override
   void initState() {
     super.initState();
-    _scrollController.addListener(_onScroll);
-    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadInitial());
+    _pageController = PageController(initialPage: 0);
   }
 
   @override
   void dispose() {
-    _scrollController
-      ..removeListener(_onScroll)
-      ..dispose();
+    _pageController.dispose();
     _searchController.dispose();
     super.dispose();
   }
 
-  void _maybeLoadInitial() {
-    if (!mounted || _didRequestInitial) return;
-    final state = ref.read(notesListProvider);
-    if (state.page == 0 &&
-        !state.isInitialLoading &&
-        state.items.isEmpty &&
-        state.errorMessage == null) {
-      _didRequestInitial = true;
-      ref.read(notesListProvider.notifier).loadInitial();
-    }
-  }
+  int _tabIndex(NotesFilterTab tab) => _tabOrder.indexOf(tab);
 
-  void _onScroll() {
-    if (!_scrollController.hasClients) return;
-    final position = _scrollController.position;
-    if (position.pixels >= position.maxScrollExtent - 200) {
-      ref.read(notesListProvider.notifier).loadMore();
-    }
+  void _onTabChanged(NotesFilterTab tab) {
+    setState(() {
+      _activeTab = tab;
+    });
+    _pageController.animateToPage(
+      _tabIndex(tab),
+      duration: const Duration(milliseconds: 300),
+      curve: Curves.easeOutCubic,
+    );
   }
 
-  Future<void> _onRefresh() async {
-    final ok = await ref.read(notesListProvider.notifier).refresh();
-    if (!ok && mounted) {
-      $message.error(message: UiStrings.notesRefreshFailed);
-    }
+  void _onPageChanged(int index) {
+    setState(() {
+      _activeTab = _tabOrder[index];
+    });
   }
 
   void _onSearchSubmit() {
-    ref.read(notesListProvider.notifier).search(_searchController.text);
+    ref
+        .read(notesListQueryProvider.notifier)
+        .setKeyword(_searchController.text);
   }
 
   void _onSearchCollapsedClear() {
-    ref.read(notesListProvider.notifier).clearSearch();
+    ref.read(notesListQueryProvider.notifier).clearKeyword();
+  }
+
+  Future<void> _onCategoryTagFilterTap() async {
+    final query = ref.read(notesListQueryProvider);
+    final result = await showNotesFilterSheet(
+      context,
+      initialCategoryId: query.categoryId,
+      initialTagIds: query.tagIds,
+    );
+    if (!mounted || result == null) return;
+    ref.read(notesListQueryProvider.notifier).setCategoryTagFilter(
+          categoryId: result.categoryId,
+          tagIds: result.tagIds,
+        );
   }
 
   @override
   Widget build(BuildContext context) {
     final colorScheme = Theme.of(context).colorScheme;
-    final state = ref.watch(notesListProvider);
-    final notifier = ref.read(notesListProvider.notifier);
+    final query = ref.watch(notesListQueryProvider);
 
     return Scaffold(
       backgroundColor: colorScheme.surface,
       body: SafeArea(
         child: Column(
@@ -94,24 +106,102 @@ class _NotesListScreenState extends ConsumerState<NotesListScreen> {
               onSearchSubmit: _onSearchSubmit,
               onSearchCollapsedClear: _onSearchCollapsedClear,
               onAdd: () => context.push('/note/${AppConstants.newNoteId}'),
             ),
             Padding(
-              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
+              padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
               child: NotesFilterTabs(
-                value: state.filterTab,
-                onChanged: notifier.setFilter,
+                value: _activeTab,
+                onChanged: _onTabChanged,
+                onFilterTap: _onCategoryTagFilterTap,
+                hasActiveFilter: query.hasCategoryTagFilter,
+              ),
+            ),
+            Expanded(
+              child: PageView.builder(
+                controller: _pageController,
+                itemCount: _tabOrder.length,
+                onPageChanged: _onPageChanged,
+                itemBuilder: (context, index) =>
+                    _NotesListTabPage(tab: _tabOrder[index]),
               ),
             ),
-            Expanded(child: _buildListBody(state, notifier)),
           ],
         ),
       ),
     );
   }
+}
+
+class _NotesListTabPage extends ConsumerStatefulWidget {
+  const _NotesListTabPage({required this.tab});
+
+  final NotesFilterTab tab;
+
+  @override
+  ConsumerState<_NotesListTabPage> createState() => _NotesListTabPageState();
+}
+
+class _NotesListTabPageState extends ConsumerState<_NotesListTabPage>
+    with AutomaticKeepAliveClientMixin {
+  final _scrollController = ScrollController();
+  var _didRequestInitial = false;
+
+  @override
+  bool get wantKeepAlive => true;
+
+  @override
+  void initState() {
+    super.initState();
+    _scrollController.addListener(_onScroll);
+    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadInitial());
+  }
+
+  @override
+  void dispose() {
+    _scrollController
+      ..removeListener(_onScroll)
+      ..dispose();
+    super.dispose();
+  }
+
+  void _maybeLoadInitial() {
+    if (!mounted || _didRequestInitial) return;
+    final state = ref.read(notesListProvider(widget.tab));
+    if (state.page == 0 &&
+        !state.isInitialLoading &&
+        state.items.isEmpty &&
+        state.errorMessage == null) {
+      _didRequestInitial = true;
+      ref.read(notesListProvider(widget.tab).notifier).loadInitial();
+    }
+  }
+
+  void _onScroll() {
+    if (!_scrollController.hasClients) return;
+    final position = _scrollController.position;
+    if (position.pixels >= position.maxScrollExtent - 200) {
+      ref.read(notesListProvider(widget.tab).notifier).loadMore();
+    }
+  }
+
+  Future<void> _onRefresh() async {
+    final ok =
+        await ref.read(notesListProvider(widget.tab).notifier).refresh();
+    if (!ok && mounted) {
+      $message.error(message: UiStrings.notesRefreshFailed);
+    }
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    super.build(context);
+
+    final query = ref.watch(notesListQueryProvider);
+    final state = ref.watch(notesListProvider(widget.tab));
+    final notifier = ref.read(notesListProvider(widget.tab).notifier);
 
-  Widget _buildListBody(NotesListState state, NotesListNotifier notifier) {
     if (state.isInitialLoading && state.items.isEmpty) {
       return const Center(child: CircularProgressIndicator());
     }
 
     if (state.errorMessage != null && state.items.isEmpty) {
@@ -121,12 +211,12 @@ class _NotesListScreenState extends ConsumerState<NotesListScreen> {
         onAction: notifier.retry,
       );
     }
 
     if (state.items.isEmpty) {
-      final hasKeyword = state.keyword.trim().isNotEmpty;
-      if (state.filterTab == NotesFilterTab.pinned && !hasKeyword) {
+      final hasKeyword = query.keyword.trim().isNotEmpty;
+      if (widget.tab == NotesFilterTab.pinned && !hasKeyword) {
         return const _EmptyMessage(
           title: UiStrings.notesPinnedEmpty,
           subtitle: UiStrings.notesPinnedEmptyHint,
         );
       }
@@ -135,11 +225,10 @@ class _NotesListScreenState extends ConsumerState<NotesListScreen> {
         subtitle:
             hasKeyword ? UiStrings.noSearchResultsHint : UiStrings.noNotesHint,
       );
     }
 
-    // Footer row for load-more / end-of-list status.
     final itemCount = state.items.length + 1;
 
     return RefreshIndicator(
       onRefresh: _onRefresh,
       child: ListView.separated(
diff --git a/lib/features/notes/notes_list_state.dart b/lib/features/notes/notes_list_state.dart
index 16b1c20..83ec854 100644
--- a/lib/features/notes/notes_list_state.dart
+++ b/lib/features/notes/notes_list_state.dart
@@ -5,24 +5,20 @@ enum NotesFilterTab { all, pinned, recent }
 class NotesListState {
   const NotesListState({
     this.items = const [],
     this.page = 0,
     this.total = 0,
-    this.keyword = '',
-    this.filterTab = NotesFilterTab.all,
     this.isInitialLoading = false,
     this.isRefreshing = false,
     this.isLoadingMore = false,
     this.errorMessage,
     this.loadMoreError = false,
   });
 
   final List<NotesListItem> items;
   final int page;
   final int total;
-  final String keyword;
-  final NotesFilterTab filterTab;
   final bool isInitialLoading;
   final bool isRefreshing;
   final bool isLoadingMore;
   final String? errorMessage;
   final bool loadMoreError;
@@ -31,12 +27,10 @@ class NotesListState {
 
   NotesListState copyWith({
     List<NotesListItem>? items,
     int? page,
     int? total,
-    String? keyword,
-    NotesFilterTab? filterTab,
     bool? isInitialLoading,
     bool? isRefreshing,
     bool? isLoadingMore,
     String? errorMessage,
     bool clearError = false,
@@ -44,12 +38,10 @@ class NotesListState {
   }) {
     return NotesListState(
       items: items ?? this.items,
       page: page ?? this.page,
       total: total ?? this.total,
-      keyword: keyword ?? this.keyword,
-      filterTab: filterTab ?? this.filterTab,
       isInitialLoading: isInitialLoading ?? this.isInitialLoading,
       isRefreshing: isRefreshing ?? this.isRefreshing,
       isLoadingMore: isLoadingMore ?? this.isLoadingMore,
       errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
       loadMoreError: loadMoreError ?? this.loadMoreError,
diff --git a/lib/features/notes/widgets/notes_filter_tabs.dart b/lib/features/notes/widgets/notes_filter_tabs.dart
index 443d94c..5322dd9 100644
--- a/lib/features/notes/widgets/notes_filter_tabs.dart
+++ b/lib/features/notes/widgets/notes_filter_tabs.dart
@@ -1,20 +1,24 @@
 import 'package:flutter/material.dart';
 
 import '../../../core/constants/ui_strings.dart';
 import '../notes_list_state.dart';
 
-/// Text filter tabs for the notes list: 鍏ㄩ儴 / 缃《 / 鏈€杩?
+/// Text filter tabs for the notes list: 鍏ㄩ儴 / 缃《 / 鏈€杩? plus trailing filter icon.
 class NotesFilterTabs extends StatelessWidget {
   const NotesFilterTabs({
     super.key,
     required this.value,
     required this.onChanged,
+    required this.onFilterTap,
+    this.hasActiveFilter = false,
   });
 
   final NotesFilterTab value;
   final ValueChanged<NotesFilterTab> onChanged;
+  final VoidCallback onFilterTap;
+  final bool hasActiveFilter;
 
   static const _tabs = <(NotesFilterTab, String)>[
     (NotesFilterTab.all, UiStrings.notesFilterAll),
     (NotesFilterTab.pinned, UiStrings.notesFilterPinned),
     (NotesFilterTab.recent, UiStrings.notesFilterRecent),
@@ -35,10 +39,24 @@ class NotesFilterTabs extends StatelessWidget {
             onTap: () => onChanged(tab),
             colorScheme: colorScheme,
             textTheme: textTheme,
           ),
         ],
+        const Spacer(),
+        IconButton(
+          onPressed: onFilterTap,
+          tooltip: UiStrings.notesCategoryTagFilterTitle,
+          visualDensity: VisualDensity.compact,
+          icon: Badge(
+            isLabelVisible: hasActiveFilter,
+            smallSize: 8,
+            child: Icon(
+              Icons.filter_list,
+              color: colorScheme.onSurfaceVariant,
+            ),
+          ),
+        ),
       ],
     );
   }
 }
 

### NEW notes_list_query.dart
```dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesListQuery {
  const NotesListQuery({
    this.keyword = '',
    this.categoryId,
    this.tagIds = const [],
  });

  final String keyword;
  final String? categoryId;
  final List<String> tagIds;

  bool get hasCategoryTagFilter => categoryId != null || tagIds.isNotEmpty;

  NotesListQuery copyWith({
    String? keyword,
    String? categoryId,
    List<String>? tagIds,
    bool clearCategoryId = false,
  }) {
    return NotesListQuery(
      keyword: keyword ?? this.keyword,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      tagIds: tagIds ?? this.tagIds,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NotesListQuery &&
            keyword == other.keyword &&
            categoryId == other.categoryId &&
            _listEquals(tagIds, other.tagIds);
  }

  @override
  int get hashCode => Object.hash(keyword, categoryId, Object.hashAll(tagIds));
}

class NotesListQueryNotifier extends Notifier<NotesListQuery> {
  @override
  NotesListQuery build() => const NotesListQuery();

  void setKeyword(String keyword) {
    final trimmed = keyword.trim();
    if (state.keyword == trimmed) return;
    state = state.copyWith(keyword: trimmed);
  }

  void clearKeyword() {
    if (state.keyword.isEmpty) return;
    state = state.copyWith(keyword: '');
  }

  void setCategoryTagFilter({
    String? categoryId,
    List<String> tagIds = const [],
  }) {
    final nextTags = List<String>.from(tagIds);
    final sameCategory = state.categoryId == categoryId;
    final sameTags = _listEquals(state.tagIds, nextTags);
    if (sameCategory && sameTags) return;

    state = state.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
      tagIds: nextTags,
    );
  }
}

bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final notesListQueryProvider =
    NotifierProvider<NotesListQueryNotifier, NotesListQuery>(
  NotesListQueryNotifier.new,
);

```

### detail/editor refresh hunks

diff --git a/lib/features/notes/note_detail_screen.dart b/lib/features/notes/note_detail_screen.dart
--- a/lib/features/notes/note_detail_screen.dart
+++ b/lib/features/notes/note_detail_screen.dart
@@ -11,9 +11,12 @@ import '../../core/network/api_exception.dart';
+import '../../ui/theme/app_colors.dart';
+import 'note_attachment_actions.dart';
+import 'widgets/note_attachment_card.dart';
@@ -31,7 +34,10 @@ class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
+  String? _busyAttachmentName;
+  String? _categoryName;
+  List<String> _tagNames = const [];
@@ -87,6 +93,10 @@ class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
+        _categoryName = bundle.categoryName;
+        _tagNames = bundle.tagNames
+            .where((name) => name.isNotEmpty)
+            .toList(growable: false);
@@ -132,7 +142,7 @@ class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
-      await ref.read(notesListProvider.notifier).refresh();
+      await refreshExistingNotesLists(ref);
@@ -191,7 +201,7 @@ class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
-      await ref.read(notesListProvider.notifier).refresh();
+      await refreshExistingNotesLists(ref);
@@ -338,8 +348,32 @@ class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
+                  if (_categoryName != null || _tagNames.isNotEmpty)
+                    Padding(
+                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
+                      child: Align(
+                        alignment: Alignment.centerLeft,
+                        child: Wrap(
+                          spacing: 8,
+                          runSpacing: 8,
+                          children: [
+                            if (_categoryName != null &&
+                                _categoryName!.isNotEmpty)
+                              _DetailMetaChip(
+                                label: _categoryName!,
+                                backgroundColor: AppColors.categorySelected,
+                              ),
+                            for (final name in _tagNames)
+                              _DetailMetaChip(
+                                label: name,
+                                backgroundColor: AppColors.tagSelected,
+                              ),
+                          ],
+                        ),
+                      ),
+                    ),
-                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
+                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
@@ -412,12 +446,69 @@ class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
-          _DetailAttachmentCard(attachment: attachment),
+          NoteAttachmentCard(
+            name: attachment.name,
+            sizeLabel: attachment.sizeLabel,
+            icon: attachment.icon,
+            busy: _busyAttachmentName == attachment.name,
+            onOpen: () => _openAttachment(attachment),
+            onDownload: () => _downloadAttachment(attachment),
+          ),
+
+  Future<void> _openAttachment(_DetailAttachment attachment) async {
+    if (_busyAttachmentName != null) return;
+    setState(() => _busyAttachmentName = attachment.name);
+    try {
+      await NoteAttachmentActions.open(context, attachment.toRef());
+    } finally {
+      if (mounted) setState(() => _busyAttachmentName = null);
+    }
+  }
+
+  Future<void> _downloadAttachment(_DetailAttachment attachment) async {
+    if (_busyAttachmentName != null) return;
+    setState(() => _busyAttachmentName = attachment.name);
+    try {
+      await NoteAttachmentActions.download(context, attachment.toRef());
+    } finally {
+      if (mounted) setState(() => _busyAttachmentName = null);
+    }
+  }
+}
+
+class _DetailMetaChip extends StatelessWidget {
+  const _DetailMetaChip({
+    required this.label,
+    required this.backgroundColor,
+  });
+
+  final String label;
+  final Color backgroundColor;
+
+  @override
+  Widget build(BuildContext context) {
+    final theme = Theme.of(context);
+    return Chip(
+      label: Text(
+        label,
+        style: theme.textTheme.labelSmall?.copyWith(
+          color: Colors.black,
+          fontSize: 10,
+        ),
+      ),
+      backgroundColor: backgroundColor,
+      side: BorderSide.none,
+      visualDensity: VisualDensity.compact,
+      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
+      labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2),
+      padding: EdgeInsets.zero,
+    );
+  }
@@ -450,93 +541,43 @@ class _AttachmentCountBadge extends StatelessWidget {
-class _DetailAttachmentCard extends StatelessWidget {
-  const _DetailAttachmentCard({required this.attachment});
-
-  final _DetailAttachment attachment;
-
-  @override
-  Widget build(BuildContext context) {
-    final theme = Theme.of(context);
-    final colorScheme = theme.colorScheme;
-
-    return DecoratedBox(
-      decoration: BoxDecoration(
-        color: colorScheme.surface,
-        borderRadius: BorderRadius.circular(8),
-        border: Border.all(color: colorScheme.outlineVariant),
-      ),
-      child: Padding(
-        padding: const EdgeInsets.all(12),
-        child: Row(
-          children: [
-            Container(
-              width: 34,
-              height: 34,
-              decoration: BoxDecoration(
-                color: colorScheme.surfaceContainerHighest.withValues(
-                  alpha: 0.7,
-                ),
-                borderRadius: BorderRadius.circular(8),
-              ),
-              child: Icon(
-                attachment.icon,
-                size: 19,
-                color: colorScheme.primary,
-              ),
-            ),
-            const SizedBox(width: 12),
-            Expanded(
-              child: Column(
-                crossAxisAlignment: CrossAxisAlignment.start,
-                children: [
-                  Text(
-                    attachment.name,
-                    maxLines: 1,
-                    overflow: TextOverflow.ellipsis,
-                    style: theme.textTheme.bodyMedium?.copyWith(
-                      color: colorScheme.onSurface,
-                      fontWeight: FontWeight.w700,
-                    ),
-                  ),
-                  const SizedBox(height: 2),
-                  Text(
-                    attachment.sizeLabel,
-                    style: theme.textTheme.bodySmall?.copyWith(
-                      color: colorScheme.onSurfaceVariant,
-                    ),
-                  ),
-                ],
-              ),
-            ),
-          ],
-        ),
-      ),
-    );
-  }
-}
-
+    this.url,
+    this.mimeType,
+    this.type,
-    final key = media.qiniuKey ?? '';
-    final name = key.split('/').last;
+    final name = media.displayFileName;
-      name: name.isEmpty ? media.id : name,
+      name: name,
+      url: media.qiniuUrl,
+      mimeType: media.mimeType,
+      type: media.type,
+  final String? url;
+  final String? mimeType;
+  final String? type;
+
+  NoteAttachmentRef toRef() => NoteAttachmentRef(
+        name: name,
+        extension: extension,
+        url: url,
+        mimeType: mimeType,
+        mediaType: type,
+      );
diff --git a/lib/features/notes/note_editor_screen.dart b/lib/features/notes/note_editor_screen.dart
--- a/lib/features/notes/note_editor_screen.dart
+++ b/lib/features/notes/note_editor_screen.dart
@@ -10,12 +10,17 @@ import '../../core/constants/ui_strings.dart';
+import '../../data/models/category_dto.dart';
+import '../../data/models/tag_response_dto.dart';
+import 'note_attachment_actions.dart';
+import 'widgets/category_tag_picker_sheet.dart';
+import 'widgets/note_attachment_card.dart';
@@ -48,8 +53,13 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
+  String? _busyAttachmentName;
+  String? _categoryId;
+  String? _categoryName;
+  List<String> _tagIds = [];
+  List<String> _tagNames = []; // parallel to _tagIds
@@ -115,8 +125,32 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
+      _categoryId = note.categoryId;
+      _tagIds = List<String>.from(note.tagIds ?? const []);
+
+      // Prefer names from nested detail payload; fall back to list lookup.
+      var categoryName = bundle.categoryName;
+      var tagNames = List<String>.from(bundle.tagNames);
+      final missingCategoryName =
+          _categoryId != null && (categoryName == null || categoryName.isEmpty);
+      final missingTagNames = _tagIds.isNotEmpty &&
+          (tagNames.length != _tagIds.length ||
+              tagNames.any((name) => name.isEmpty));
+      if (missingCategoryName || missingTagNames) {
+        final resolved = await _resolveCategoryTagNames();
+        if (!mounted) return;
+        if (missingCategoryName) {
+          categoryName = resolved.categoryName;
+        }
+        if (missingTagNames) {
+          tagNames = resolved.tagNames;
+        }
+      }
+      if (!mounted) return;
+        _categoryName = categoryName;
+        _tagNames = tagNames;
@@ -315,6 +349,50 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
+  /// Resolves display names for [_categoryId] / [_tagIds].
+  ///
+  /// Failures return empty/null names so note content still loads.
+  Future<({String? categoryName, List<String> tagNames})>
+      _resolveCategoryTagNames() async {
+    final fallbackNames = List<String>.filled(_tagIds.length, '');
+    try {
+      // Start both lookups before awaiting so they run in parallel.
+      final categoriesFuture =
+          ref.read(categoriesServiceProvider).getCategoryTree();
+      final tagsFuture = ref.read(tagsServiceProvider).getTags();
+      final categoriesResponse = await categoriesFuture;
+      final tagsResponse = await tagsFuture;
+
+      String? categoryName;
+      if (_categoryId != null && categoriesResponse.isSuccess) {
+        final tree = categoriesResponse.data ?? const <CategoryDto>[];
+        for (final category in tree) {
+          if (category.id == _categoryId) {
+            categoryName = category.name;
+            break;
+          }
+        }
+      }
+
+      final tagNames = <String>[];
+      if (tagsResponse.isSuccess) {
+        final tags = tagsResponse.data ?? const <TagResponseDto>[];
+        final byId = <String, String>{
+          for (final tag in tags) tag.id: tag.name,
+        };
+        for (final id in _tagIds) {
+          tagNames.add(byId[id] ?? '');
+        }
+      } else {
+        tagNames.addAll(fallbackNames);
+      }
+
+      return (categoryName: categoryName, tagNames: tagNames);
+    } catch (_) {
+      return (categoryName: null, tagNames: fallbackNames);
+    }
+  }
+
@@ -333,6 +411,8 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
+            categoryId: _categoryId,
+            tagIds: _tagIds.isEmpty ? null : _tagIds,
@@ -342,6 +422,8 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
+            categoryId: _categoryId,
+            tagIds: _tagIds,
@@ -377,7 +459,7 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
-      await ref.read(notesListProvider.notifier).refresh();
+      await refreshExistingNotesLists(ref);
@@ -437,6 +519,79 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
+  Future<void> _openCategoryTagPicker() async {
+    final result = await showCategoryTagPickerSheet(
+      context,
+      initialCategoryId: _categoryId,
+      initialTagIds: List<String>.from(_tagIds),
+    );
+    if (!mounted || result == null) return;
+    setState(() {
+      _categoryId = result.categoryId;
+      _categoryName = result.categoryName;
+      _tagIds = List<String>.from(result.tagIds);
+      _tagNames = List<String>.from(result.tagNames);
+      _isDirty = true;
+    });
+  }
+
+  Widget _buildCategoryTagSection() {
+    final theme = Theme.of(context);
+    final colorScheme = theme.colorScheme;
+    final hasCategory = _categoryName != null && _categoryName!.isNotEmpty;
+    // Skip empty lookup misses so unknown tag ids do not render blank chips.
+    final visibleTagNames =
+        _tagNames.where((name) => name.isNotEmpty).toList(growable: false);
+    final hasTags = visibleTagNames.isNotEmpty;
+
+    return Column(
+      crossAxisAlignment: CrossAxisAlignment.stretch,
+      children: [
+        _CategoryTagRow(
+          label: UiStrings.noteEditorCategoryLabel,
+          onTap: _openCategoryTagPicker,
+          child: hasCategory
+              ? _EditorMetaChip(
+                  label: _categoryName!,
+                  backgroundColor: AppColors.categorySelected,
+                )
+              : Text(
+                  UiStrings.noteEditorCategoryPlaceholder,
+                  style: theme.textTheme.bodySmall?.copyWith(
+                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
+                  ),
+                ),
+        ),
+        Divider(
+          height: 1,
+          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
+        ),
+        _CategoryTagRow(
+          label: UiStrings.noteEditorTagsLabel,
+          onTap: _openCategoryTagPicker,
+          child: hasTags
+              ? Wrap(
+                  spacing: 4,
+                  runSpacing: 4,
+                  children: [
+                    for (final name in visibleTagNames)
+                      _EditorMetaChip(
+                        label: name,
+                        backgroundColor: AppColors.tagSelected,
+                      ),
+                  ],
+                )
+              : Text(
+                  UiStrings.noteEditorTagsPlaceholder,
+                  style: theme.textTheme.bodySmall?.copyWith(
+                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
+                  ),
+                ),
+        ),
+      ],
+    );
+  }
+
@@ -444,7 +599,9 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
-        const SizedBox(height: 22),
+        const SizedBox(height: 12),
+        _buildCategoryTagSection(),
+        // const SizedBox(height: 22),
@@ -463,6 +620,8 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
+              const SizedBox(height: 12),
+              _buildCategoryTagSection(),
@@ -526,8 +685,13 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
-              _AttachmentCard(
-                attachment: attachment,
+              NoteAttachmentCard(
+                name: attachment.name,
+                sizeLabel: attachment.sizeLabel,
+                icon: attachment.icon,
+                busy: _busyAttachmentName == attachment.name,
+                onOpen: () => _openAttachment(attachment),
+                onDownload: () => _downloadAttachment(attachment),
@@ -542,6 +706,26 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
+  Future<void> _openAttachment(_EditorAttachment attachment) async {
+    if (_busyAttachmentName != null) return;
+    setState(() => _busyAttachmentName = attachment.name);
+    try {
+      await NoteAttachmentActions.open(context, attachment.toRef());
+    } finally {
+      if (mounted) setState(() => _busyAttachmentName = null);
+    }
+  }
+
+  Future<void> _downloadAttachment(_EditorAttachment attachment) async {
+    if (_busyAttachmentName != null) return;
+    setState(() => _busyAttachmentName = attachment.name);
+    try {
+      await NoteAttachmentActions.download(context, attachment.toRef());
+    } finally {
+      if (mounted) setState(() => _busyAttachmentName = null);
+    }
+  }
+
@@ -670,82 +854,6 @@ class _AttachmentCountBadge extends StatelessWidget {
-class _AttachmentCard extends StatelessWidget {
-  const _AttachmentCard({required this.attachment, required this.onRemove});
-
-  final _EditorAttachment attachment;
-  final VoidCallback onRemove;
-
-  @override
-  Widget build(BuildContext context) {
-    final theme = Theme.of(context);
-    final colorScheme = theme.colorScheme;
-
-    return DecoratedBox(
-      decoration: BoxDecoration(
-        color: colorScheme.surface,
-        borderRadius: BorderRadius.circular(8),
-        border: Border.all(color: colorScheme.outlineVariant),
-      ),
-      child: Padding(
-        padding: const EdgeInsets.all(12),
-        child: Row(
-          children: [
-            Container(
-              width: 34,
-              height: 34,
-              decoration: BoxDecoration(
-                color: colorScheme.surfaceContainerHighest.withValues(
-                  alpha: 0.7,
-                ),
-                borderRadius: BorderRadius.circular(8),
-              ),
-              child: Icon(
-                attachment.icon,
-                size: 19,
-                color: colorScheme.primary,
-              ),
-            ),
-            const SizedBox(width: 12),
-            Expanded(
-              child: Column(
-                crossAxisAlignment: CrossAxisAlignment.start,
-                children: [
-                  Text(
-                    attachment.name,
-                    maxLines: 1,
-                    overflow: TextOverflow.ellipsis,
-                    style: theme.textTheme.bodyMedium?.copyWith(
-                      color: colorScheme.onSurface,
-                      fontWeight: FontWeight.w700,
-                    ),
-                  ),
-                  const SizedBox(height: 2),
-                  Text(
-                    attachment.sizeLabel,
-                    style: theme.textTheme.bodySmall?.copyWith(
-                      color: colorScheme.onSurfaceVariant,
-                    ),
-                  ),
-                ],
-              ),
-            ),
-            IconButton(
-              onPressed: onRemove,
-              tooltip: UiStrings.deleteNote,
-              icon: Icon(
-                Icons.close,
-                size: 18,
-                color: colorScheme.onSurfaceVariant,
-              ),
-            ),
-          ],
-        ),
-      ),
-    );
-  }
-}
-
@@ -953,6 +1061,92 @@ class _ToolbarButton extends StatelessWidget {
+class _CategoryTagRow extends StatelessWidget {
+  const _CategoryTagRow({
+    required this.label,
+    required this.child,
+    required this.onTap,
+  });
+
+  final String label;
+  final Widget child;
+  final VoidCallback onTap;
+
+  @override
+  Widget build(BuildContext context) {
+    final theme = Theme.of(context);
+    final colorScheme = theme.colorScheme;
+
+    return Material(
+      color: Colors.transparent,
+      child: InkWell(
+        onTap: onTap,
+        child: Padding(
+          padding: const EdgeInsets.symmetric(vertical: 8),
+          child: Row(
+            crossAxisAlignment: CrossAxisAlignment.center,
+            children: [
+              SizedBox(
+                width: 40,
+                child: Text(
+                  label,
+                  style: theme.textTheme.bodySmall?.copyWith(
+                    color: colorScheme.onSurfaceVariant,
+                    fontWeight: FontWeight.w500,
+                  ),
+                ),
+              ),
+              const SizedBox(width: 8),
+              Expanded(
+                child: Align(
+                  alignment: Alignment.centerLeft,
+                  child: child,
+                ),
+              ),
+              const SizedBox(width: 4),
+              Icon(
+                Icons.chevron_right,
+                size: 18,
+                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
+              ),
+            ],
+          ),
+        ),
+      ),
+    );
+  }
+}
+
+class _EditorMetaChip extends StatelessWidget {
+  const _EditorMetaChip({
+    required this.label,
+    required this.backgroundColor,
+  });
+
+  final String label;
+  final Color backgroundColor;
+
+  @override
+  Widget build(BuildContext context) {
+    final theme = Theme.of(context);
+    return Chip(
+      label: Text(
+        label,
+        style: theme.textTheme.labelSmall?.copyWith(
+          color: Colors.black,
+          fontSize: 11,
+        ),
+      ),
+      backgroundColor: backgroundColor,
+      side: BorderSide.none,
+      visualDensity: VisualDensity.compact,
+      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
+      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
+      padding: EdgeInsets.zero,
+    );
+  }
+}
+
@@ -965,11 +1159,10 @@ class _EditorAttachment {
-    final key = media.qiniuKey ?? '';
-    final name = key.split('/').last;
+    final name = media.displayFileName;
-      name: name.isEmpty ? media.id : name,
+      name: name,
@@ -1002,6 +1195,14 @@ class _EditorAttachment {
+  NoteAttachmentRef toRef() => NoteAttachmentRef(
+        name: name,
+        extension: extension,
+        url: url,
+        localPath: path,
+        bytes: bytes,
+      );
+
