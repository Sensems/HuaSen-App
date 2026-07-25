# Review package Task 5
Focus on load/save category/tag wiring hunks.

   import '../../core/network/api_exception.dart';
   import '../../core/providers/core_providers.dart';
   import '../../data/models/api_response.dart';
> +import '../../data/models/category_dto.dart';
   import '../../data/models/note_dtos.dart';
> +import '../../data/models/tag_response_dto.dart';
   import '../../ui/components/custom_app_bar.dart';
   import '../../ui/theme/app_colors.dart';
   import '../wechat/drafts_list_notifier.dart';
  +import 'note_attachment_actions.dart';
   import 'notes_list_notifier.dart';
   import 'quill_content_codec.dart';
> +import 'widgets/category_tag_picker_sheet.dart';
  +import 'widgets/note_attachment_card.dart';
   
   /// Placeholder screen for editing or creating a note.
  +  String? _busyAttachmentName;
     String? _loadErrorMessage;
     String? _loadedType;
> +  String? _categoryId;
> +  String? _categoryName;
> +  List<String> _tagIds = [];
> +  List<String> _tagNames = []; // parallel to _tagIds
   
     bool get _isNew => widget.noteId == 'new';
     bool get _isWide => MediaQuery.of(context).size.width >= 600;
   
         _titleController.text = note.title ?? '';
         _loadedType = note.type;
> +      _categoryId = note.categoryId;
> +      _tagIds = List<String>.from(note.tagIds ?? const []);
  +
  +      // Name lookup must not fail the whole note load.
> +      final resolved = await _resolveCategoryTagNames();
  +      if (!mounted) return;
   
         setState(() {
> +        _categoryName = resolved.categoryName;
> +        _tagNames = resolved.tagNames;
           _attachments
             ..clear()
             ..addAll(bundle.media.map(_EditorAttachment.fromNoteMedia));
       return ids;
     }
   
> +  /// Resolves display names for [_categoryId] / [_tagIds].
  +  ///
  +  /// Failures return empty/null names so note content still loads.
> +  Future<({String? categoryName, List<String> tagNames})>
> +      _resolveCategoryTagNames() async {
> +    final fallbackNames = List<String>.filled(_tagIds.length, '');
  +    try {
  +      // Start both lookups before awaiting so they run in parallel.
  +      final categoriesFuture =
> +          ref.read(categoriesServiceProvider).getCategoryTree();
> +      final tagsFuture = ref.read(tagsServiceProvider).getTags();
  +      final categoriesResponse = await categoriesFuture;
> +      final tagsResponse = await tagsFuture;
  +
> +      String? categoryName;
> +      if (_categoryId != null && categoriesResponse.isSuccess) {
> +        final tree = categoriesResponse.data ?? const <CategoryDto>[];
> +        for (final category in tree) {
> +          if (category.id == _categoryId) {
> +            categoryName = category.name;
  +            break;
  +          }
  +        }
  +      }
  +
> +      final tagNames = <String>[];
> +      if (tagsResponse.isSuccess) {
> +        final tags = tagsResponse.data ?? const <TagResponseDto>[];
  +        final byId = <String, String>{
> +          for (final tag in tags) tag.id: tag.name,
  +        };
> +        for (final id in _tagIds) {
> +          tagNames.add(byId[id] ?? '');
  +        }
  +      } else {
> +        tagNames.addAll(fallbackNames);
  +      }
  +
> +      return (categoryName: categoryName, tagNames: tagNames);
  +    } catch (_) {
> +      return (categoryName: null, tagNames: fallbackNames);
  +    }
  +  }
  +
>    Future<void> _onSave() async {
       if (_saving || _loading) return;
       setState(() => _saving = true);
       try {
   
         final ApiResponse<NoteDetailDto> saveResponse;
         if (_isNew) {
>          saveResponse = await notes.createNote(
>            CreateNoteDto(
               title: title.isEmpty ? null : title,
               content: content,
               source: NoteSource.appManual,
> +            categoryId: _categoryId,
> +            tagIds: _tagIds.isEmpty ? null : _tagIds,
               mediaIds: mediaIds.isEmpty ? null : mediaIds,
             ),
           );
         } else {
>          saveResponse = await notes.updateNote(
>            UpdateNoteDto(
               id: widget.noteId,
               title: title.isEmpty ? null : title,
               content: content,
> +            categoryId: _categoryId,
> +            tagIds: _tagIds,
               mediaIds: mediaIds,
             ),
           );
       }
     }
   
> +  Future<void> _openCategoryTagPicker() async {
> +    final result = await showCategoryTagPickerSheet(
  +      context,
> +      initialCategoryId: _categoryId,
> +      initialTagIds: List<String>.from(_tagIds),
  +    );
  +    if (!mounted || result == null) return;
  +    setState(() {
> +      _categoryId = result.categoryId;
> +      _categoryName = result.categoryName;
> +      _tagIds = List<String>.from(result.tagIds);
> +      _tagNames = List<String>.from(result.tagNames);
  +      _isDirty = true;
  +    });
  +  }
  +
> +  Widget _buildCategoryTagSection() {
  +    final theme = Theme.of(context);
  +    final colorScheme = theme.colorScheme;
> +    final hasCategory = _categoryName != null && _categoryName!.isNotEmpty;
> +    // Skip empty lookup misses so unknown tag ids do not render blank chips.
> +    final visibleTagNames =
> +        _tagNames.where((name) => name.isNotEmpty).toList(growable: false);
> +    final hasTags = visibleTagNames.isNotEmpty;
  +
  +    return Column(
  +      crossAxisAlignment: CrossAxisAlignment.stretch,
  +      children: [
> +        _CategoryTagRow(
> +          label: UiStrings.noteEditorCategoryLabel,
> +          onTap: _openCategoryTagPicker,
  +          child: Text(
> +            hasCategory
> +                ? _categoryName!
> +                : UiStrings.noteEditorCategoryPlaceholder,
  +            style: theme.textTheme.bodyMedium?.copyWith(
> +              color: hasCategory
  +                  ? colorScheme.onSurface
  +                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
  +            ),
  +          height: 1,
  +          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
  +        ),
> +        _CategoryTagRow(
> +          label: UiStrings.noteEditorTagsLabel,
> +          onTap: _openCategoryTagPicker,
> +          child: hasTags
  +              ? Wrap(
  +                  spacing: 6,
  +                  runSpacing: 6,
  +                  children: [
> +                    for (final name in visibleTagNames)
> +                      _SelectedTagChip(label: name),
  +                  ],
  +                )
  +              : Text(
> +                  UiStrings.noteEditorTagsPlaceholder,
  +                  style: theme.textTheme.bodyMedium?.copyWith(
  +                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
  +                  ),
         children: [
           _buildTitleField(),
  +        const SizedBox(height: 8),
> +        _buildCategoryTagSection(),
           const SizedBox(height: 16),
           _buildEditorSection(),
           const SizedBox(height: 22),
               children: [
                 _buildTitleField(),
  +              const SizedBox(height: 8),
> +              _buildCategoryTagSection(),
                 const SizedBox(height: 16),
                 _buildEditorSection(),
               ],
     }
   }
   
> +class _CategoryTagRow extends StatelessWidget {
> +  const _CategoryTagRow({
  +    required this.label,
  +    required this.child,
  +    required this.onTap,
  +  }
  +}
  +
> +class _SelectedTagChip extends StatelessWidget {
> +  const _SelectedTagChip({required this.label});
  +
  +  final String label;
  +




===== FULL DIFF (editor) =====

diff --git a/lib/features/notes/note_editor_screen.dart b/lib/features/notes/note_editor_screen.dart
index 6205c75..aa6d241 100644
--- a/lib/features/notes/note_editor_screen.dart
+++ b/lib/features/notes/note_editor_screen.dart
@@ -7,18 +7,23 @@ import 'package:go_router/go_router.dart';
 import 'package:tolyui_message/tolyui_message.dart';
 
 import '../../core/constants/ui_strings.dart';
 import '../../core/network/api_exception.dart';
 import '../../core/providers/core_providers.dart';
 import '../../data/models/api_response.dart';
+import '../../data/models/category_dto.dart';
 import '../../data/models/note_dtos.dart';
+import '../../data/models/tag_response_dto.dart';
 import '../../ui/components/custom_app_bar.dart';
 import '../../ui/theme/app_colors.dart';
 import '../wechat/drafts_list_notifier.dart';
+import 'note_attachment_actions.dart';
 import 'notes_list_notifier.dart';
 import 'quill_content_codec.dart';
+import 'widgets/category_tag_picker_sheet.dart';
+import 'widgets/note_attachment_card.dart';
 
 /// Placeholder screen for editing or creating a note.
 ///
 /// Shows a title input, a placeholder area for the rich text editor, and a
 /// placeholder area for media attachments. The note [id] is received from
 /// the route parameter 鈥?`new` indicates a new note.
@@ -45,14 +50,19 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
   final List<_EditorAttachment> _attachments = [];
   var _isDirty = false;
   var _isPickingFile = false;
   var _loading = false;
   var _loadFailed = false;
   var _saving = false;
+  String? _busyAttachmentName;
   String? _loadErrorMessage;
   String? _loadedType;
+  String? _categoryId;
+  String? _categoryName;
+  List<String> _tagIds = [];
+  List<String> _tagNames = []; // parallel to _tagIds
 
   bool get _isNew => widget.noteId == 'new';
   bool get _isWide => MediaQuery.of(context).size.width >= 600;
 
   @override
   void initState() {
@@ -112,14 +122,22 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
       } finally {
         _quillController.addListener(_markDirty);
       }
 
       _titleController.text = note.title ?? '';
       _loadedType = note.type;
+      _categoryId = note.categoryId;
+      _tagIds = List<String>.from(note.tagIds ?? const []);
+
+      // Name lookup must not fail the whole note load.
+      final resolved = await _resolveCategoryTagNames();
+      if (!mounted) return;
 
       setState(() {
+        _categoryName = resolved.categoryName;
+        _tagNames = resolved.tagNames;
         _attachments
           ..clear()
           ..addAll(bundle.media.map(_EditorAttachment.fromNoteMedia));
         _isDirty = false;
         _loading = false;
         _loadFailed = false;
@@ -312,12 +330,56 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
       );
       ids.add(mediaId);
     }
     return ids;
   }
 
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
   Future<void> _onSave() async {
     if (_saving || _loading) return;
     setState(() => _saving = true);
     try {
       final mediaIds = await _collectMediaIds();
       if (mediaIds == null) return;
@@ -330,21 +392,25 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
       if (_isNew) {
         saveResponse = await notes.createNote(
           CreateNoteDto(
             title: title.isEmpty ? null : title,
             content: content,
             source: NoteSource.appManual,
+            categoryId: _categoryId,
+            tagIds: _tagIds.isEmpty ? null : _tagIds,
             mediaIds: mediaIds.isEmpty ? null : mediaIds,
           ),
         );
       } else {
         saveResponse = await notes.updateNote(
           UpdateNoteDto(
             id: widget.noteId,
             title: title.isEmpty ? null : title,
             content: content,
+            categoryId: _categoryId,
+            tagIds: _tagIds,
             mediaIds: mediaIds,
           ),
         );
       }
 
       if (!saveResponse.isSuccess || saveResponse.data == null) {
@@ -434,17 +500,90 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
   void _markDirty() {
     if (!_isDirty) {
       setState(() => _isDirty = true);
     }
   }
 
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
+          child: Text(
+            hasCategory
+                ? _categoryName!
+                : UiStrings.noteEditorCategoryPlaceholder,
+            style: theme.textTheme.bodyMedium?.copyWith(
+              color: hasCategory
+                  ? colorScheme.onSurface
+                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
+            ),
+            maxLines: 1,
+            overflow: TextOverflow.ellipsis,
+          ),
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
+                  spacing: 6,
+                  runSpacing: 6,
+                  children: [
+                    for (final name in visibleTagNames)
+                      _SelectedTagChip(label: name),
+                  ],
+                )
+              : Text(
+                  UiStrings.noteEditorTagsPlaceholder,
+                  style: theme.textTheme.bodyMedium?.copyWith(
+                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
+                  ),
+                ),
+        ),
+      ],
+    );
+  }
+
   Widget _buildMobileBody() {
     return ListView(
       padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
       children: [
         _buildTitleField(),
+        const SizedBox(height: 8),
+        _buildCategoryTagSection(),
         const SizedBox(height: 16),
         _buildEditorSection(),
         const SizedBox(height: 22),
         _buildAttachmentSection(),
       ],
     );
@@ -458,12 +597,14 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
         Expanded(
           flex: 3,
           child: ListView(
             padding: const EdgeInsets.all(24),
             children: [
               _buildTitleField(),
+              const SizedBox(height: 8),
+              _buildCategoryTagSection(),
               const SizedBox(height: 16),
               _buildEditorSection(),
             ],
           ),
         ),
         // Media pane
@@ -523,14 +664,19 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
                 const Spacer(),
                 _AttachmentCountBadge(count: _attachments.length),
               ],
             ),
             const SizedBox(height: 14),
             for (final attachment in _attachments) ...[
-              _AttachmentCard(
-                attachment: attachment,
+              NoteAttachmentCard(
+                name: attachment.name,
+                sizeLabel: attachment.sizeLabel,
+                icon: attachment.icon,
+                busy: _busyAttachmentName == attachment.name,
+                onOpen: () => _openAttachment(attachment),
+                onDownload: () => _downloadAttachment(attachment),
                 onRemove: () => _removeAttachment(attachment),
               ),
               const SizedBox(height: 10),
             ],
             _AddAttachmentButton(
               isLoading: _isPickingFile,
@@ -539,12 +685,32 @@ class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
           ],
         ),
       ),
     );
   }
 
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
   Future<void> _pickAttachments() async {
     if (_isPickingFile) return;
     setState(() => _isPickingFile = true);
 
     try {
       final result = await FilePicker.pickFiles(
@@ -667,88 +833,12 @@ class _AttachmentCountBadge extends StatelessWidget {
         ),
       ),
     );
   }
 }
 
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
 class _AddAttachmentButton extends StatelessWidget {
   const _AddAttachmentButton({
     required this.isLoading,
     required this.onPressed,
   });
 
@@ -950,29 +1040,107 @@ class _ToolbarButton extends StatelessWidget {
         ),
       ),
     );
   }
 }
 
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
+          padding: const EdgeInsets.symmetric(vertical: 12),
+          child: Row(
+            crossAxisAlignment: CrossAxisAlignment.center,
+            children: [
+              SizedBox(
+                width: 48,
+                child: Text(
+                  label,
+                  style: theme.textTheme.bodyMedium?.copyWith(
+                    color: colorScheme.onSurfaceVariant,
+                    fontWeight: FontWeight.w500,
+                  ),
+                ),
+              ),
+              const SizedBox(width: 8),
+              Expanded(child: child),
+              const SizedBox(width: 4),
+              Icon(
+                Icons.chevron_right,
+                size: 22,
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
+class _SelectedTagChip extends StatelessWidget {
+  const _SelectedTagChip({required this.label});
+
+  final String label;
+
+  @override
+  Widget build(BuildContext context) {
+    final theme = Theme.of(context);
+    final colorScheme = theme.colorScheme;
+
+    return Container(
+      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
+      decoration: BoxDecoration(
+        borderRadius: BorderRadius.circular(16),
+        border: Border.all(color: colorScheme.outlineVariant),
+        color: AppColors.success.withValues(alpha: 0.12),
+      ),
+      child: Text(
+        label,
+        style: theme.textTheme.labelMedium?.copyWith(
+          color: AppColors.success,
+          fontWeight: FontWeight.w600,
+        ),
+      ),
+    );
+  }
+}
+
 class _EditorAttachment {
   const _EditorAttachment({
     required this.name,
     required this.size,
     this.extension,
     this.path,
     this.bytes,
     this.mediaId,
     this.url,
   });
 
   factory _EditorAttachment.fromNoteMedia(NoteMediaItemDto media) {
-    final key = media.qiniuKey ?? '';
-    final name = key.split('/').last;
+    final name = media.displayFileName;
     final extension = name.contains('.') ? name.split('.').last : null;
     return _EditorAttachment(
-      name: name.isEmpty ? media.id : name,
+      name: name,
       size: media.fileSize ?? 0,
       extension: extension,
       mediaId: media.id,
       url: media.qiniuUrl,
     );
   }
@@ -999,12 +1167,20 @@ class _EditorAttachment {
   final List<int>? bytes;
   final String? mediaId;
   final String? url;
 
   bool get isRemote => mediaId != null && bytes == null;
 
+  NoteAttachmentRef toRef() => NoteAttachmentRef(
+        name: name,
+        extension: extension,
+        url: url,
+        localPath: path,
+        bytes: bytes,
+      );
+
   String get sizeLabel {
     if (size < 1024) return '$size B';
     final kb = size / 1024;
     if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
     final mb = kb / 1024;
     return '${mb.toStringAsFixed(1)} MB';
