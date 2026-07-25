# Review Package — Filter Task 1

Base: working tree vs HEAD (9190586) — no commits for this task
Head: working tree

## Commits
(none — working-tree only)

## Stat
 lib/core/constants/ui_strings.dart          | 29 +++++++++++++++++++
 lib/data/services/notes_service.dart        |  4 +++
 lib/features/notes/notes_list_notifier.dart | 44 +++++++++++++++++++++++++++++
 lib/features/notes/notes_list_state.dart    | 13 +++++++++
 4 files changed, 90 insertions(+)


## Diff
diff --git a/lib/core/constants/ui_strings.dart b/lib/core/constants/ui_strings.dart
index b2a1b1c..605155f 100644
--- a/lib/core/constants/ui_strings.dart
+++ b/lib/core/constants/ui_strings.dart
@@ -14,20 +14,23 @@ abstract final class UiStrings {
   static const String navDrafts = '草稿';
   static const String navSettings = '设置';
 
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
   static const String notesRefreshFailed = '刷新失败';
   static const String notesLoadMoreFailed = '加载更多失败，点击重试';
@@ -48,20 +51,46 @@ abstract final class UiStrings {
   static const String noteEditorLoadFailed = '加载笔记失败，请重试';
   static const String noteEditorRetry = '重试';
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
   static const String noteDetailDeleteConfirmMessage =
       '确定删除这条笔记吗？删除后无法恢复。';
diff --git a/lib/data/services/notes_service.dart b/lib/data/services/notes_service.dart
index abb9988..2edfe55 100644
--- a/lib/data/services/notes_service.dart
+++ b/lib/data/services/notes_service.dart
@@ -17,32 +17,34 @@ class NotesService {
   /// GET /notes
   ///
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
     );
     return ApiResponse.fromJson(
@@ -106,20 +108,22 @@ class NotesService {
         final map = json as Map<String, dynamic>;
         final media = (map['media'] as List<dynamic>?)
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
   Future<ApiResponse<NoteDetailDto>> createNote(CreateNoteDto dto) async {
     final response = await _dio.post<Map<String, dynamic>>(
diff --git a/lib/features/notes/notes_list_notifier.dart b/lib/features/notes/notes_list_notifier.dart
index e213757..24864a9 100644
--- a/lib/features/notes/notes_list_notifier.dart
+++ b/lib/features/notes/notes_list_notifier.dart
@@ -107,35 +107,79 @@ class NotesListNotifier extends Notifier<NotesListState> {
       total: 0,
       isInitialLoading: true,
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
 
       final data = response.data;
       if (response.isSuccess && data != null) {
diff --git a/lib/features/notes/notes_list_state.dart b/lib/features/notes/notes_list_state.dart
index 16b1c20..e64476a 100644
--- a/lib/features/notes/notes_list_state.dart
+++ b/lib/features/notes/notes_list_state.dart
@@ -2,57 +2,70 @@ import '../../data/models/note_dtos.dart';
 
 enum NotesFilterTab { all, pinned, recent }
 
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

