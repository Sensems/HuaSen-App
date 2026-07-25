# Final Review Package — Notes List Category/Tag Filter

Base: 9190586 (spec commit)
Head: working tree (no feature commits)

## Feature files only

## Stat
 lib/core/constants/ui_strings.dart                | 29 +++++++++++++++
 lib/data/services/notes_service.dart              |  4 +++
 lib/features/notes/notes_list_notifier.dart       | 44 +++++++++++++++++++++++
 lib/features/notes/notes_list_screen.dart         | 19 +++++++++-
 lib/features/notes/notes_list_state.dart          | 13 +++++++
 lib/features/notes/widgets/notes_filter_tabs.dart | 20 ++++++++++-
 6 files changed, 127 insertions(+), 2 deletions(-)

 notes_filter_sheet.dart (new) | 297 +

## Diff (modified tracked files)
diff --git a/lib/core/constants/ui_strings.dart b/lib/core/constants/ui_strings.dart
index b2a1b1c..605155f 100644
--- a/lib/core/constants/ui_strings.dart
+++ b/lib/core/constants/ui_strings.dart
@@ -16,16 +16,19 @@ abstract final class UiStrings {
 
   // --- Notes list screen ---
   static const String notesBrandTitle = '花森';
   static const String searchNotes = '搜索笔记';
   static const String searchNotesHint = '输入关键词';
   static const String notesFilterAll = '全部';
   static const String notesFilterPinned = '置顶';
   static const String notesFilterRecent = '最近';
+  static const String notesCategoryTagFilterTitle = '筛选';
+  static const String notesCategoryTagFilterConfirm = '确认';
+  static const String notesCategoryTagFilterClear = '清除';
   static const String noNotesFound = '还没有笔记';
   static const String noNotesHint = '点击右上角 + 创建第一条笔记';
   static const String noSearchResults = '没有找到相关笔记';
   static const String noSearchResultsHint = '试试其他关键词';
   static const String notesPinnedEmpty = '暂无置顶笔记';
   static const String notesPinnedEmptyHint = '置顶同步能力待后端支持';
   static const String notesLoadFailed = '加载失败，请重试';
   static const String notesRetry = '重试';
@@ -50,16 +53,42 @@ abstract final class UiStrings {
   static const String noteEditorAttachmentUploadFailed = '附件上传失败，请重试';
   static const String noteEditorAttachmentBytesMissing = '无法读取附件内容，请重新添加';
   static const String noteEditorNetworkError = '网络异常，请重试';
   static const String noteEditorPickFileFailed = '选择附件失败，请重试';
   static const String noteEditorLinkTitle = '添加链接';
   static const String noteEditorLinkHint = 'https://example.com';
   static const String noteEditorLinkEmpty = '请输入链接地址';
 
+  // --- Note editor category / tags ---
+  static const String noteEditorCategoryLabel = '分类';
+  static const String noteEditorTagsLabel = '标签';
+  static const String noteEditorCategoryPlaceholder = '选择分类';
+  static const String noteEditorTagsPlaceholder = '选择标签';
+  static const String categoryTagPickerTitle = '分类与标签';
+  static const String categoryTagPickerSelectCategory = '选择分类（单选）';
+  static const String categoryTagPickerSelectTags = '选择标签（多选）';
+  static const String categoryTagPickerNewCategoryHint = '新建分类...';
+  static const String categoryTagPickerNewTagHint = '新建标签...';
+  static const String categoryTagPickerAdd = '添加';
+  static const String categoryTagPickerDone = '完成';
+  static const String categoryTagPickerLoadFailed = '加载失败，请重试';
+  static const String categoryTagPickerRetry = '重试';
+  static const String categoryTagPickerEmptyName = '请输入名称';
+
+  // --- Note attachment open/download ---
+  static const String attachmentOpenFailed = '无法打开该文件';
+  static const String attachmentDownloadFailed = '下载失败，请重试';
+  static const String attachmentDownloadSuccess = '已保存到下载目录';
+  static const String attachmentSourceMissing = '文件不可用';
+  static const String attachmentOpening = '正在打开…';
+  static const String attachmentDownloading = '正在下载…';
+  static const String attachmentImagePreviewTitle = '预览';
+  static const String attachmentDownloadTooltip = '下载';
+
   // --- Note detail screen ---
   static const String noteDetailPageTitle = '笔记详情';
   static const String noteDetailPin = '置顶';
   static const String noteDetailUnpin = '取消置顶';
   static const String noteDetailDelete = '删除';
   static const String noteDetailEdit = '编辑';
   static const String noteDetailPinnedBadge = '置顶';
   static const String noteDetailDeleteConfirmTitle = '确认删除';
diff --git a/lib/data/services/notes_service.dart b/lib/data/services/notes_service.dart
index abb9988..2edfe55 100644
--- a/lib/data/services/notes_service.dart
+++ b/lib/data/services/notes_service.dart
@@ -19,28 +19,30 @@ class NotesService {
   /// Each item may include a joined `media` array from the same JSON object
   /// (no N+1). Missing/`null` `media` becomes an empty list.
   Future<ApiResponse<PaginatedNotesList>> listNotes({
     int? page,
     int? size,
     String? type,
     String? category,
     String? tag,
+    List<String>? tags,
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
+        'tags': (tags == null || tags.isEmpty) ? null : tags,
         'keyword': keyword,
         'mediaType': mediaType,
         'view': switch (view) {
           NotesListView.pinned => 'pinned',
           NotesListView.recent => 'recent',
           null => null,
         },
       }..removeWhere((_, v) => v == null),
@@ -108,16 +110,18 @@ class NotesService {
                 ?.map(
                   (e) => NoteMediaItemDto.fromJson(e as Map<String, dynamic>),
                 )
                 .toList() ??
             const <NoteMediaItemDto>[];
         return NoteDetailBundle(
           note: NoteDetailDto.fromJson(map),
           media: media,
+          categoryName: extractNoteCategoryName(map),
+          tagNames: extractNoteTagNames(map),
         );
       },
     );
   }
 
   /// Create a new note.
   ///
   /// POST /notes/create
diff --git a/lib/features/notes/notes_list_notifier.dart b/lib/features/notes/notes_list_notifier.dart
index e213757..24864a9 100644
--- a/lib/features/notes/notes_list_notifier.dart
+++ b/lib/features/notes/notes_list_notifier.dart
@@ -109,31 +109,75 @@ class NotesListNotifier extends Notifier<NotesListState> {
       isRefreshing: false,
       isLoadingMore: false,
       clearError: true,
       loadMoreError: false,
     );
     return _fetchPage(page: 1, replace: true, generation: generation);
   }
 
+  /// Apply category/tag filters and reload page 1.
+  Future<bool> setCategoryTagFilter({
+    String? categoryId,
+    List<String> tagIds = const [],
+  }) async {
+    final nextTags = List<String>.from(tagIds);
+    final sameCategory = state.categoryId == categoryId;
+    final sameTags = _listEquals(state.tagIds, nextTags);
+    if (sameCategory && sameTags) return true;
+
+    final generation = ++_fetchGeneration;
+    state = state.copyWith(
+      categoryId: categoryId,
+      clearCategoryId: categoryId == null,
+      tagIds: nextTags,
+      items: const [],
+      page: 0,
+      total: 0,
+      isInitialLoading: true,
+      isRefreshing: false,
+      isLoadingMore: false,
+      clearError: true,
+      loadMoreError: false,
+    );
+    return _fetchPage(page: 1, replace: true, generation: generation);
+  }
+
+  Future<bool> clearCategoryTagFilter() => setCategoryTagFilter(
+        categoryId: null,
+        tagIds: const [],
+      );
+
+  static bool _listEquals(List<String> a, List<String> b) {
+    if (identical(a, b)) return true;
+    if (a.length != b.length) return false;
+    for (var i = 0; i < a.length; i++) {
+      if (a[i] != b[i]) return false;
+    }
+    return true;
+  }
+
   Future<void> retry() => loadInitial();
 
   Future<bool> _fetchPage({
     required int page,
     required bool replace,
     required int generation,
     bool isRefresh = false,
   }) async {
     try {
       final keyword = state.keyword.trim();
+      final tags = state.tagIds;
       final response = await ref.read(notesServiceProvider).listNotes(
             page: page,
             size: AppConstants.notesPageSize,
             type: 'PUBLISHED',
             keyword: keyword.isEmpty ? null : keyword,
+            category: state.categoryId,
+            tags: tags.isEmpty ? null : tags,
             view: switch (state.filterTab) {
               NotesFilterTab.pinned => NotesListView.pinned,
               NotesFilterTab.recent => NotesListView.recent,
               NotesFilterTab.all => null,
             },
           );
       if (generation != _fetchGeneration) return false;
 
diff --git a/lib/features/notes/notes_list_screen.dart b/lib/features/notes/notes_list_screen.dart
index 082d311..cacdf0e 100644
--- a/lib/features/notes/notes_list_screen.dart
+++ b/lib/features/notes/notes_list_screen.dart
@@ -4,16 +4,17 @@ import 'package:go_router/go_router.dart';
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
 
@@ -72,16 +73,30 @@ class _NotesListScreenState extends ConsumerState<NotesListScreen> {
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
@@ -91,20 +106,22 @@ class _NotesListScreenState extends ConsumerState<NotesListScreen> {
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
diff --git a/lib/features/notes/notes_list_state.dart b/lib/features/notes/notes_list_state.dart
index 16b1c20..e64476a 100644
--- a/lib/features/notes/notes_list_state.dart
+++ b/lib/features/notes/notes_list_state.dart
@@ -4,55 +4,68 @@ enum NotesFilterTab { all, pinned, recent }
 
 class NotesListState {
   const NotesListState({
     this.items = const [],
     this.page = 0,
     this.total = 0,
     this.keyword = '',
     this.filterTab = NotesFilterTab.all,
+    this.categoryId,
+    this.tagIds = const [],
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
+  final String? categoryId;
+  final List<String> tagIds;
   final bool isInitialLoading;
   final bool isRefreshing;
   final bool isLoadingMore;
   final String? errorMessage;
   final bool loadMoreError;
 
   bool get hasMore => items.length < total;
 
+  bool get hasCategoryTagFilter =>
+      categoryId != null || tagIds.isNotEmpty;
+
   NotesListState copyWith({
     List<NotesListItem>? items,
     int? page,
     int? total,
     String? keyword,
     NotesFilterTab? filterTab,
+    String? categoryId,
+    List<String>? tagIds,
+    bool clearCategoryId = false,
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
+      categoryId:
+          clearCategoryId ? null : (categoryId ?? this.categoryId),
+      tagIds: tagIds ?? this.tagIds,
       isInitialLoading: isInitialLoading ?? this.isInitialLoading,
       isRefreshing: isRefreshing ?? this.isRefreshing,
       isLoadingMore: isLoadingMore ?? this.isLoadingMore,
       errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
       loadMoreError: loadMoreError ?? this.loadMoreError,
     );
   }
 }
diff --git a/lib/features/notes/widgets/notes_filter_tabs.dart b/lib/features/notes/widgets/notes_filter_tabs.dart
index 443d94c..5322dd9 100644
--- a/lib/features/notes/widgets/notes_filter_tabs.dart
+++ b/lib/features/notes/widgets/notes_filter_tabs.dart
@@ -1,23 +1,27 @@
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


## Diff (new file notes_filter_sheet.dart)
diff --git a/lib/features/notes/widgets/notes_filter_sheet.dart b/lib/features/notes/widgets/notes_filter_sheet.dart
new file mode 100644
--- /dev/null
+++ b/lib/features/notes/widgets/notes_filter_sheet.dart
@@ -0,0 +1,297 @@
+import 'package:dio/dio.dart';
+import 'package:flutter/material.dart';
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:tolyui_message/tolyui_message.dart';
+
+import '../../../core/constants/ui_strings.dart';
+import '../../../core/network/api_exception.dart';
+import '../../../core/providers/core_providers.dart';
+import '../../../data/models/category_dto.dart';
+import '../../../data/models/tag_response_dto.dart';
+import '../../../ui/components/custom_button.dart';
+import '../../../ui/theme/app_colors.dart';
+
+/// Result from confirm/clear. Dismiss via X/barrier returns null instead.
+class NotesFilterResult {
+  const NotesFilterResult({
+    this.categoryId,
+    this.tagIds = const [],
+  });
+
+  final String? categoryId;
+  final List<String> tagIds;
+}
+
+/// Prefetch categories/tags then show the select-only filter sheet.
+Future<NotesFilterResult?> showNotesFilterSheet(
+  BuildContext context, {
+  String? initialCategoryId,
+  List<String> initialTagIds = const [],
+}) async {
+  final container = ProviderScope.containerOf(context);
+  final categoriesService = container.read(categoriesServiceProvider);
+  final tagsService = container.read(tagsServiceProvider);
+
+  List<CategoryDto> categories;
+  List<TagResponseDto> tags;
+  try {
+    final categoriesResponse = await categoriesService.getCategoryTree();
+    final tagsResponse = await tagsService.getTags();
+
+    if (!categoriesResponse.isSuccess || !tagsResponse.isSuccess) {
+      final message = categoriesResponse.isSuccess
+          ? tagsResponse.message
+          : categoriesResponse.message;
+      $message.error(
+        message: message.isNotEmpty
+            ? message
+            : UiStrings.categoryTagPickerLoadFailed,
+      );
+      return null;
+    }
+    categories = categoriesResponse.data ?? const <CategoryDto>[];
+    tags = tagsResponse.data ?? const <TagResponseDto>[];
+  } on DioException catch (error) {
+    final apiError = error.error;
+    $message.error(
+      message: apiError is ApiException && apiError.message.isNotEmpty
+          ? apiError.message
+          : UiStrings.categoryTagPickerLoadFailed,
+    );
+    return null;
+  } on Object {
+    $message.error(message: UiStrings.categoryTagPickerLoadFailed);
+    return null;
+  }
+
+  if (!context.mounted) return null;
+
+  return showModalBottomSheet<NotesFilterResult>(
+    context: context,
+    isScrollControlled: true,
+    useSafeArea: true,
+    shape: const RoundedRectangleBorder(
+      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
+    ),
+    builder: (sheetContext) => NotesFilterSheet(
+      initialCategoryId: initialCategoryId,
+      initialTagIds: initialTagIds,
+      initialCategories: categories,
+      initialTags: tags,
+    ),
+  );
+}
+
+class NotesFilterSheet extends StatefulWidget {
+  const NotesFilterSheet({
+    super.key,
+    this.initialCategoryId,
+    this.initialTagIds = const [],
+    required this.initialCategories,
+    required this.initialTags,
+  });
+
+  final String? initialCategoryId;
+  final List<String> initialTagIds;
+  final List<CategoryDto> initialCategories;
+  final List<TagResponseDto> initialTags;
+
+  @override
+  State<NotesFilterSheet> createState() => _NotesFilterSheetState();
+}
+
+class _NotesFilterSheetState extends State<NotesFilterSheet> {
+  late final List<CategoryDto> _categories;
+  late final List<TagResponseDto> _tags;
+  String? _selectedCategoryId;
+  late List<String> _selectedTagIds;
+
+  @override
+  void initState() {
+    super.initState();
+    _categories = List<CategoryDto>.from(widget.initialCategories);
+    _tags = List<TagResponseDto>.from(widget.initialTags);
+    _selectedCategoryId = widget.initialCategoryId;
+    _selectedTagIds = List<String>.from(widget.initialTagIds);
+  }
+
+  void _toggleCategory(String id) {
+    setState(() {
+      _selectedCategoryId = _selectedCategoryId == id ? null : id;
+    });
+  }
+
+  void _toggleTag(String id) {
+    setState(() {
+      if (_selectedTagIds.contains(id)) {
+        _selectedTagIds = List<String>.from(_selectedTagIds)..remove(id);
+      } else {
+        _selectedTagIds = List<String>.from(_selectedTagIds)..add(id);
+      }
+    });
+  }
+
+  void _popResult({String? categoryId, List<String> tagIds = const []}) {
+    Navigator.of(context).pop(
+      NotesFilterResult(categoryId: categoryId, tagIds: tagIds),
+    );
+  }
+
+  void _onConfirm() {
+    _popResult(
+      categoryId: _selectedCategoryId,
+      tagIds: List<String>.from(_selectedTagIds),
+    );
+  }
+
+  void _onClear() {
+    _popResult(categoryId: null, tagIds: const []);
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    final theme = Theme.of(context);
+    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
+    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
+
+    return Padding(
+      padding: EdgeInsets.only(bottom: bottomInset),
+      child: ConstrainedBox(
+        constraints: BoxConstraints(maxHeight: maxHeight),
+        child: Column(
+          mainAxisSize: MainAxisSize.min,
+          children: [
+            Padding(
+              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
+              child: Row(
+                children: [
+                  Expanded(
+                    child: Text(
+                      UiStrings.notesCategoryTagFilterTitle,
+                      style: theme.textTheme.titleMedium?.copyWith(
+                        fontWeight: FontWeight.w700,
+                      ),
+                    ),
+                  ),
+                  IconButton(
+                    onPressed: () => Navigator.of(context).pop(),
+                    icon: const Icon(Icons.close),
+                    tooltip:
+                        MaterialLocalizations.of(context).closeButtonTooltip,
+                  ),
+                ],
+              ),
+            ),
+            Flexible(
+              fit: FlexFit.loose,
+              child: ListView(
+                shrinkWrap: true,
+                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
+                children: [
+                  Text(
+                    UiStrings.categoryTagPickerSelectCategory,
+                    style: theme.textTheme.titleSmall?.copyWith(
+                      fontWeight: FontWeight.w600,
+                    ),
+                  ),
+                  const SizedBox(height: 10),
+                  Wrap(
+                    spacing: 8,
+                    runSpacing: 8,
+                    children: [
+                      for (final category in _categories)
+                        ChoiceChip(
+                          label: Text(
+                            category.name,
+                            style: theme.textTheme.bodySmall?.copyWith(
+                              color: Colors.black,
+                            ),
+                          ),
+                          selected: _selectedCategoryId == category.id,
+                          onSelected: (_) => _toggleCategory(category.id),
+                          showCheckmark: false,
+                          color: WidgetStateProperty.resolveWith((states) {
+                            if (states.contains(WidgetState.selected)) {
+                              return AppColors.categorySelected;
+                            }
+                            return null;
+                          }),
+                          visualDensity: VisualDensity.compact,
+                          materialTapTargetSize:
+                              MaterialTapTargetSize.shrinkWrap,
+                          labelPadding:
+                              const EdgeInsets.symmetric(horizontal: 6),
+                          padding: const EdgeInsets.symmetric(horizontal: 4),
+                        ),
+                    ],
+                  ),
+                  const SizedBox(height: 18),
+                  Text(
+                    UiStrings.categoryTagPickerSelectTags,
+                    style: theme.textTheme.titleSmall?.copyWith(
+                      fontWeight: FontWeight.w600,
+                    ),
+                  ),
+                  const SizedBox(height: 10),
+                  Wrap(
+                    spacing: 8,
+                    runSpacing: 8,
+                    children: [
+                      for (final tag in _tags)
+                        FilterChip(
+                          label: Text(
+                            tag.name,
+                            style: theme.textTheme.bodySmall?.copyWith(
+                              color: Colors.black,
+                            ),
+                          ),
+                          selected: _selectedTagIds.contains(tag.id),
+                          onSelected: (_) => _toggleTag(tag.id),
+                          showCheckmark: false,
+                          color: WidgetStateProperty.resolveWith((states) {
+                            if (states.contains(WidgetState.selected)) {
+                              return AppColors.tagSelected;
+                            }
+                            return null;
+                          }),
+                          visualDensity: VisualDensity.compact,
+                          materialTapTargetSize:
+                              MaterialTapTargetSize.shrinkWrap,
+                          labelPadding:
+                              const EdgeInsets.symmetric(horizontal: 6),
+                          padding: const EdgeInsets.symmetric(horizontal: 4),
+                        ),
+                    ],
+                  ),
+                ],
+              ),
+            ),
+            Padding(
+              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
+              child: Row(
+                children: [
+                  Expanded(
+                    child: CustomButton(
+                      label: UiStrings.notesCategoryTagFilterClear,
+                      variant: CustomButtonVariant.secondary,
+                      expanded: true,
+                      onPressed: _onClear,
+                    ),
+                  ),
+                  const SizedBox(width: 12),
+                  Expanded(
+                    child: CustomButton(
+                      label: UiStrings.notesCategoryTagFilterConfirm,
+                      expanded: true,
+                      onPressed: _onConfirm,
+                    ),
+                  ),
+                ],
+              ),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+}
