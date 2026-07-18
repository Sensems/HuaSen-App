import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/api_response.dart';
import '../../data/models/note_dtos.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/theme/app_colors.dart';
import '../wechat/drafts_list_notifier.dart';
import 'notes_list_notifier.dart';
import 'quill_content_codec.dart';

/// Placeholder screen for editing or creating a note.
///
/// Shows a title input, a placeholder area for the rich text editor, and a
/// placeholder area for media attachments. The note [id] is received from
/// the route parameter — `new` indicates a new note.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.noteId});

  /// The note identifier from the route path. Use `'new'` for creation.
  final String noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  // Field initializers so hot reload cannot leave these unset.
  final FocusNode _titleFocusNode = FocusNode();
  // Must outlive rebuilds — QuillEditor.basic() otherwise allocates a new
  // FocusNode/ScrollController every build, which steals focus (double-tap)
  // and can crash selection overlays when opening dialogs.
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  late final quill.QuillController _quillController;
  final List<_EditorAttachment> _attachments = [];
  var _isDirty = false;
  var _isPickingFile = false;
  var _loading = false;
  var _loadFailed = false;
  var _saving = false;
  String? _loadErrorMessage;
  String? _loadedType;

  bool get _isNew => widget.noteId == 'new';
  bool get _isWide => MediaQuery.of(context).size.width >= 600;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _quillController = quill.QuillController.basic();
    _quillController.addListener(_markDirty);

    // One-shot focus for new notes — avoid TextField.autofocus: true, which
    // can re-request the IME after keyboard-dismiss rebuilds on Android.
    if (_isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _titleFocusNode.requestFocus();
      });
    } else {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadExisting();
      });
    }
  }

  Future<void> _loadExisting() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
      _loadErrorMessage = null;
    });

    try {
      final detailResponse =
          await ref.read(notesServiceProvider).getNoteDetailBundle(widget.noteId);
      if (!mounted) return;

      if (!detailResponse.isSuccess || detailResponse.data == null) {
        setState(() {
          _loading = false;
          _loadFailed = true;
          _loadErrorMessage = detailResponse.message.isNotEmpty
              ? detailResponse.message
              : UiStrings.noteEditorLoadFailed;
        });
        return;
      }

      final bundle = detailResponse.data!;
      final note = bundle.note;
      final document = decodeNoteContent(note.content);
      _quillController.removeListener(_markDirty);
      try {
        _quillController
          ..document = document
          ..updateSelection(
            const TextSelection.collapsed(offset: 0),
            quill.ChangeSource.silent,
          );
      } finally {
        _quillController.addListener(_markDirty);
      }

      _titleController.text = note.title ?? '';
      _loadedType = note.type;

      setState(() {
        _attachments
          ..clear()
          ..addAll(bundle.media.map(_EditorAttachment.fromNoteMedia));
        _isDirty = false;
        _loading = false;
        _loadFailed = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      final apiError = error.error;
      setState(() {
        _loading = false;
        _loadFailed = true;
        _loadErrorMessage =
            apiError is ApiException && apiError.message.isNotEmpty
            ? apiError.message
            : UiStrings.noteEditorLoadFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
        _loadErrorMessage = UiStrings.noteEditorLoadFailed;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _quillController
      ..removeListener(_markDirty)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: const CustomAppBar(
          title: UiStrings.noteEditorPageTitleEdit,
          showBack: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadFailed) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: const CustomAppBar(
          title: UiStrings.noteEditorPageTitleEdit,
          showBack: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadErrorMessage ?? UiStrings.noteEditorLoadFailed,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loadExisting,
                  child: const Text(UiStrings.noteEditorRetry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorScheme.surface,
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(
            title: _isNew
                ? UiStrings.noteEditorPageTitleNew
                : UiStrings.noteEditorPageTitleEdit,
            showBack: true,
            actions: [
              TextButton(
                onPressed: _saving ? null : _onSave,
                child: Text(
                  UiStrings.noteEditorSave,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _saving
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: _isWide ? _buildWideBody() : _buildMobileBody(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: _EditorToolbar(
                    controller: _quillController,
                    onLink: _showLinkDialog,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_saving)
          const Positioned.fill(
            child: ModalBarrier(dismissible: false, color: Color(0x33000000)),
          ),
        if (_saving) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  String _storageTypeFor(_EditorAttachment attachment) {
    final extension = attachment.extension?.toLowerCase();
    if (extension == 'png' ||
        extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'webp' ||
        extension == 'gif') {
      return 'IMAGE';
    }
    if (extension == 'mp3' ||
        extension == 'm4a' ||
        extension == 'wav' ||
        extension == 'aac') {
      return 'VOICE';
    }
    if (extension == 'mp4' || extension == 'mov' || extension == 'webm') {
      return 'VIDEO';
    }
    return 'FILE';
  }

  Future<List<String>?> _collectMediaIds() async {
    final storage = ref.read(storageServiceProvider);
    final ids = <String>[];
    for (var index = 0; index < _attachments.length; index++) {
      final attachment = _attachments[index];
      final existing = attachment.mediaId;
      if (existing != null && attachment.bytes == null) {
        ids.add(existing);
        continue;
      }

      final bytes = attachment.bytes;
      if (bytes == null || bytes.isEmpty) {
        $message.error(message: UiStrings.noteEditorAttachmentBytesMissing);
        return null;
      }

      final upload = await storage.uploadFile(
        bytes,
        filename: attachment.name,
        type: _storageTypeFor(attachment),
      );
      if (!upload.isSuccess || upload.data == null) {
        $message.error(
          message: upload.message.isNotEmpty
              ? upload.message
              : UiStrings.noteEditorAttachmentUploadFailed,
        );
        return null;
      }
      final mediaId = upload.data!.mediaId;
      _attachments[index] = attachment.copyWith(
        mediaId: mediaId,
        clearBytes: true,
      );
      ids.add(mediaId);
    }
    return ids;
  }

  Future<void> _onSave() async {
    if (_saving || _loading) return;
    setState(() => _saving = true);
    try {
      final mediaIds = await _collectMediaIds();
      if (mediaIds == null) return;

      final title = _titleController.text.trim();
      final content = encodeQuillDocument(_quillController.document);
      final notes = ref.read(notesServiceProvider);

      final ApiResponse<NoteDetailDto> saveResponse;
      if (_isNew) {
        saveResponse = await notes.createNote(
          CreateNoteDto(
            title: title.isEmpty ? null : title,
            content: content,
            source: NoteSource.appManual,
            mediaIds: mediaIds.isEmpty ? null : mediaIds,
          ),
        );
      } else {
        saveResponse = await notes.updateNote(
          UpdateNoteDto(
            id: widget.noteId,
            title: title.isEmpty ? null : title,
            content: content,
            mediaIds: mediaIds,
          ),
        );
      }

      if (!saveResponse.isSuccess || saveResponse.data == null) {
        $message.error(
          message: saveResponse.message.isNotEmpty
              ? saveResponse.message
              : UiStrings.noteEditorNetworkError,
        );
        return;
      }

      final note = saveResponse.data!;
      final type = (note.type ?? _loadedType)?.toUpperCase();
      if (type != 'PUBLISHED') {
        final publishResponse = await notes.publishNote(note.id);
        if (!publishResponse.isSuccess || publishResponse.data == null) {
          $message.error(
            message: publishResponse.message.isNotEmpty
                ? publishResponse.message
                : UiStrings.noteEditorNetworkError,
          );
          return;
        }
      }

      _isDirty = false;
      $message.success(
        message: saveResponse.message.isNotEmpty
            ? saveResponse.message
            : UiStrings.noteEditorSaved,
      );

      await ref.read(notesListProvider.notifier).refresh();
      await ref.read(draftsListProvider.notifier).refresh();

      if (!mounted) return;
      context.pop();
    } on DioException catch (error) {
      final apiError = error.error;
      $message.error(
        message: apiError is ApiException && apiError.message.isNotEmpty
            ? apiError.message
            : UiStrings.noteEditorNetworkError,
      );
    } catch (_) {
      $message.error(message: UiStrings.noteEditorNetworkError);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _buildTitleField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: _titleController,
      focusNode: _titleFocusNode,
      onChanged: (_) => _markDirty(),
      style: theme.textTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      decoration: InputDecoration(
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintText: UiStrings.noteEditorTitleHint,
        hintStyle: theme.textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  Widget _buildMobileBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        _buildTitleField(),
        const SizedBox(height: 16),
        _buildEditorSection(),
        const SizedBox(height: 22),
        _buildAttachmentSection(),
      ],
    );
  }

  Widget _buildWideBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Editor pane
        Expanded(
          flex: 3,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildEditorSection(),
            ],
          ),
        ),
        // Media pane
        Expanded(
          flex: 2,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [_buildAttachmentSection()],
          ),
        ),
      ],
    );
  }

  Widget _buildEditorSection() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 190),
      child: quill.QuillEditor.basic(
        controller: _quillController,
        focusNode: _editorFocusNode,
        scrollController: _editorScrollController,
        config: const quill.QuillEditorConfig(
          placeholder: UiStrings.noteEditorContentHint,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  UiStrings.noteEditorAttachments,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                _AttachmentCountBadge(count: _attachments.length),
              ],
            ),
            const SizedBox(height: 14),
            for (final attachment in _attachments) ...[
              _AttachmentCard(
                attachment: attachment,
                onRemove: () => _removeAttachment(attachment),
              ),
              const SizedBox(height: 10),
            ],
            _AddAttachmentButton(
              isLoading: _isPickingFile,
              onPressed: _pickAttachments,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAttachments() async {
    if (_isPickingFile) return;
    setState(() => _isPickingFile = true);

    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      if (!mounted) return;

      final selected = result.files.map((file) {
        return _EditorAttachment(
          name: file.name,
          size: file.size,
          extension: file.extension,
          path: file.path,
          bytes: file.bytes,
        );
      }).toList();

      if (selected.isEmpty) return;
      setState(() {
        _attachments.addAll(selected);
        _isDirty = true;
      });
    } catch (_) {
      $message.error(message: UiStrings.noteEditorPickFileFailed);
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  void _removeAttachment(_EditorAttachment attachment) {
    setState(() {
      _attachments.remove(attachment);
      _isDirty = true;
    });
  }

  Future<void> _showLinkDialog() async {
    // Preserve selection across the dialog; apply after the route closes so
    // Quill's selection overlay is not torn down mid-InheritedWidget update.
    final selection = _quillController.selection;
    final urlController = TextEditingController();

    try {
      final url = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(UiStrings.noteEditorLinkTitle),
            content: TextField(
              controller: urlController,
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: UiStrings.noteEditorLinkHint,
              ),
              onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(UiStrings.cancel),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(urlController.text),
                child: const Text(UiStrings.confirm),
              ),
            ],
          );
        },
      );

      if (!mounted || url == null) return;

      final trimmed = url.trim();
      if (trimmed.isEmpty) {
        $message.error(message: UiStrings.noteEditorLinkEmpty);
        return;
      }

      _quillController
        ..updateSelection(selection, quill.ChangeSource.local)
        ..formatSelection(quill.LinkAttribute(trimmed));
      _editorFocusNode.requestFocus();
    } finally {
      urlController.dispose();
    }
  }
}

class _AttachmentCountBadge extends StatelessWidget {
  const _AttachmentCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 22,
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({required this.attachment, required this.onRemove});

  final _EditorAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.7,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                attachment.icon,
                size: 19,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attachment.sizeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              tooltip: UiStrings.deleteNote,
              icon: Icon(
                Icons.close,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAttachmentButton extends StatelessWidget {
  const _AddAttachmentButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(UiStrings.noteEditorAttach),
    );
  }
}

class _EditorToolbar extends StatefulWidget {
  const _EditorToolbar({required this.controller, required this.onLink});

  final quill.QuillController controller;
  final VoidCallback onLink;

  @override
  State<_EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<_EditorToolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant _EditorToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // M3 Expressive Floating Toolbar: elevated pill pinned to page bottom.
    return Center(
      child: Material(
        color: AppColors.elevatedSurfaceOf(context),
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToolbarButton(
                label: 'B',
                isActive: _isActive(quill.Attribute.bold),
                onPressed: () => _toggle(quill.Attribute.bold),
              ),
              _ToolbarButton(
                label: 'I',
                isActive: _isActive(quill.Attribute.italic),
                onPressed: () => _toggle(quill.Attribute.italic),
              ),
              _ToolbarButton(
                label: 'H2',
                isActive: _isActive(quill.Attribute.h2),
                onPressed: () => _toggle(quill.Attribute.h2),
              ),
              _ToolbarButton(
                icon: Icons.format_list_bulleted,
                isActive: _isActive(quill.Attribute.ul),
                onPressed: () => _toggle(quill.Attribute.ul),
              ),
              _ToolbarButton(
                icon: Icons.link,
                isActive: _hasAttribute(quill.Attribute.link),
                onPressed: widget.onLink,
              ),
              _ToolbarButton(
                icon: Icons.undo,
                isActive: false,
                onPressed: widget.controller.hasUndo
                    ? widget.controller.undo
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _isActive(quill.Attribute<dynamic> attribute) {
    final selectedAttribute = widget.controller
        .getSelectionStyle()
        .attributes[attribute.key];
    return selectedAttribute?.value == attribute.value;
  }

  bool _hasAttribute(quill.Attribute<dynamic> attribute) {
    final selectedAttribute = widget.controller
        .getSelectionStyle()
        .attributes[attribute.key];
    return selectedAttribute?.value != null;
  }

  void _toggle(quill.Attribute<dynamic> attribute) {
    final nextAttribute = _isActive(attribute)
        ? quill.Attribute.clone(attribute, null)
        : attribute;
    widget.controller.formatSelection(nextAttribute);
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    this.label,
    this.icon,
    this.isActive = false,
    required this.onPressed,
  }) : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = onPressed != null;
    final foregroundColor = isActive
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withValues(alpha: isEnabled ? 1 : 0.38);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 36,
        height: 34,
        child: Material(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 18, color: foregroundColor)
                  : Text(
                      label!,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: foregroundColor,
                        fontStyle: label == 'I'
                            ? FontStyle.italic
                            : FontStyle.normal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

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
    final key = media.qiniuKey ?? '';
    final name = key.split('/').last;
    final extension = name.contains('.') ? name.split('.').last : null;
    return _EditorAttachment(
      name: name.isEmpty ? media.id : name,
      size: media.fileSize ?? 0,
      extension: extension,
      mediaId: media.id,
      url: media.qiniuUrl,
    );
  }

  _EditorAttachment copyWith({
    String? mediaId,
    bool clearBytes = false,
  }) {
    return _EditorAttachment(
      name: name,
      size: size,
      extension: extension,
      path: path,
      bytes: clearBytes ? null : bytes,
      mediaId: mediaId ?? this.mediaId,
      url: url,
    );
  }

  final String name;
  final int size;
  final String? extension;
  final String? path;
  final List<int>? bytes;
  final String? mediaId;
  final String? url;

  bool get isRemote => mediaId != null && bytes == null;

  String get sizeLabel {
    if (size < 1024) return '$size B';
    final kb = size / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  IconData get icon {
    final ext = extension?.toLowerCase();
    if (ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'webp') {
      return Icons.image_outlined;
    }
    if (ext == 'mp3' || ext == 'm4a' || ext == 'wav' || ext == 'aac') {
      return Icons.mic_none;
    }
    if (ext == 'pdf') {
      return Icons.description_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }
}
