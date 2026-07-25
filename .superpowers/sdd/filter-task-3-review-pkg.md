# Review Package — Filter Task 3

Base: working tree vs HEAD
Head: working tree

## Commits
(none)

## Stat
 lib/features/notes/notes_list_screen.dart         | 19 ++++++++++++++++++-
 lib/features/notes/widgets/notes_filter_tabs.dart | 20 +++++++++++++++++++-
 2 files changed, 37 insertions(+), 2 deletions(-)


## Diff
diff --git a/lib/features/notes/notes_list_screen.dart b/lib/features/notes/notes_list_screen.dart
index 082d311..cacdf0e 100644
--- a/lib/features/notes/notes_list_screen.dart
+++ b/lib/features/notes/notes_list_screen.dart
@@ -2,20 +2,21 @@ import 'package:flutter/material.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
 import 'package:go_router/go_router.dart';
 import 'package:tolyui_message/tolyui_message.dart';
 
 import '../../core/constants/app_constants.dart';
 import '../../core/constants/ui_strings.dart';
 import 'notes_list_notifier.dart';
 import 'notes_list_state.dart';
 import 'widgets/expandable_search_button.dart';
 import 'widgets/note_list_card.dart';
+import 'widgets/notes_filter_sheet.dart';
 import 'widgets/notes_filter_tabs.dart';
 
 /// Notes list with sticky brand header, filter tabs, and paginated API data.
 ///
 /// Bottom navigation is owned by the shell (Task 5) — this screen has none.
 class NotesListScreen extends ConsumerStatefulWidget {
   const NotesListScreen({super.key});
 
   @override
   ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
@@ -70,43 +71,59 @@ class _NotesListScreenState extends ConsumerState<NotesListScreen> {
   }
 
   void _onSearchSubmit() {
     ref.read(notesListProvider.notifier).search(_searchController.text);
   }
 
   void _onSearchCollapsedClear() {
     ref.read(notesListProvider.notifier).clearSearch();
   }
 
+  Future<void> _onCategoryTagFilterTap() async {
+    final state = ref.read(notesListProvider);
+    final result = await showNotesFilterSheet(
+      context,
+      initialCategoryId: state.categoryId,
+      initialTagIds: state.tagIds,
+    );
+    if (!mounted || result == null) return;
+    await ref.read(notesListProvider.notifier).setCategoryTagFilter(
+          categoryId: result.categoryId,
+          tagIds: result.tagIds,
+        );
+  }
+
   @override
   Widget build(BuildContext context) {
     final colorScheme = Theme.of(context).colorScheme;
     final state = ref.watch(notesListProvider);
     final notifier = ref.read(notesListProvider.notifier);
 
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
                 value: state.filterTab,
                 onChanged: notifier.setFilter,
+                onFilterTap: _onCategoryTagFilterTap,
+                hasActiveFilter: state.hasCategoryTagFilter,
               ),
             ),
             Expanded(child: _buildListBody(state, notifier)),
           ],
         ),
       ),
     );
   }
 
   Widget _buildListBody(NotesListState state, NotesListNotifier notifier) {
diff --git a/lib/features/notes/widgets/notes_filter_tabs.dart b/lib/features/notes/widgets/notes_filter_tabs.dart
index 443d94c..5322dd9 100644
--- a/lib/features/notes/widgets/notes_filter_tabs.dart
+++ b/lib/features/notes/widgets/notes_filter_tabs.dart
@@ -1,25 +1,29 @@
 import 'package:flutter/material.dart';
 
 import '../../../core/constants/ui_strings.dart';
 import '../notes_list_state.dart';
 
-/// Text filter tabs for the notes list: 全部 / 置顶 / 最近.
+/// Text filter tabs for the notes list: 全部 / 置顶 / 最近, plus trailing filter icon.
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
   Widget build(BuildContext context) {
     final colorScheme = Theme.of(context).colorScheme;
@@ -30,20 +34,34 @@ class NotesFilterTabs extends StatelessWidget {
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
     required this.selected,
     required this.onTap,

