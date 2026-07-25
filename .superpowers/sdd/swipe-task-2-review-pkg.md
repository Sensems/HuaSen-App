# Review package — Task 2 (working tree)

## Status
 M lib/features/notes/notes_list_screen.dart
 M lib/features/notes/widgets/notes_filter_tabs.dart

## Diff stat

 lib/features/notes/notes_list_screen.dart         | 168 ++++++++++++++++------
 lib/features/notes/widgets/notes_filter_tabs.dart |  20 ++-
 2 files changed, 146 insertions(+), 42 deletions(-)

## Full diff

diff --git a/lib/features/notes/notes_list_screen.dart b/lib/features/notes/notes_list_screen.dart
index 082d311..e34c46e 100644
--- a/lib/features/notes/notes_list_screen.dart
+++ b/lib/features/notes/notes_list_screen.dart
@@ -1,148 +1,234 @@
 import 'package:flutter/material.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
 import 'package:go_router/go_router.dart';
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
 class NotesListScreen extends ConsumerStatefulWidget {
   const NotesListScreen({super.key});
 
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
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             _Header(
               searchController: _searchController,
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
+              child: PageView(
+                controller: _pageController,
+                onPageChanged: _onPageChanged,
+                children: [
+                  for (final tab in _tabOrder) _NotesListTabPage(tab: tab),
+                ],
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
       return _EmptyMessage(
         title: state.errorMessage!,
         actionLabel: UiStrings.notesRetry,
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
       return _EmptyMessage(
         title: hasKeyword ? UiStrings.noSearchResults : UiStrings.noNotesFound,
         subtitle:
             hasKeyword ? UiStrings.noSearchResultsHint : UiStrings.noNotesHint,
       );
     }
 
-    // Footer row for load-more / end-of-list status.
     final itemCount = state.items.length + 1;
 
     return RefreshIndicator(
       onRefresh: _onRefresh,
       child: ListView.separated(
         controller: _scrollController,
         physics: const AlwaysScrollableScrollPhysics(),
         padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
diff --git a/lib/features/notes/widgets/notes_filter_tabs.dart b/lib/features/notes/widgets/notes_filter_tabs.dart
index 443d94c..5322dd9 100644
--- a/lib/features/notes/widgets/notes_filter_tabs.dart
+++ b/lib/features/notes/widgets/notes_filter_tabs.dart
@@ -1,23 +1,27 @@
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
   ];
 
   @override
@@ -32,16 +36,30 @@ class NotesFilterTabs extends StatelessWidget {
           _FilterTab(
             label: label,
             selected: value == tab,
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
 
 class _FilterTab extends StatelessWidget {
   const _FilterTab({
     required this.label,
