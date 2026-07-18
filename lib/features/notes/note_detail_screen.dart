import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/note_dtos.dart';
import '../../ui/components/custom_app_bar.dart';
import 'note_time_format.dart';
import 'notes_list_notifier.dart';
import 'quill_content_codec.dart';

/// Read-only note detail screen with pin, delete, and edit entry.
class NoteDetailScreen extends ConsumerStatefulWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  var _loading = true;
  var _loadFailed = false;
  var _pinning = false;
  var _deleting = false;
  String? _loadErrorMessage;
  NoteDetailDto? _note;
  List<_DetailAttachment> _attachments = const [];
  late quill.QuillController _quillController;
  final _editorFocusNode = FocusNode();
  final _scrollController = ScrollController();

  bool get _actionsBusy => _pinning || _deleting || _loading;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _quillController.dispose();
    _editorFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
      _loadErrorMessage = null;
    });
    try {
      final response =
          await ref.read(notesServiceProvider).getNoteDetailBundle(widget.noteId);
      if (!mounted) return;
      if (!response.isSuccess || response.data == null) {
        setState(() {
          _loading = false;
          _loadFailed = true;
          _loadErrorMessage = response.message.isNotEmpty
              ? response.message
              : UiStrings.noteDetailLoadFailed;
        });
        return;
      }
      final bundle = response.data!;
      final document = decodeNoteContent(bundle.note.content);
      _quillController
        ..document = document
        ..readOnly = true
        ..updateSelection(
          const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.silent,
        );
      setState(() {
        _note = bundle.note;
        _attachments =
            bundle.media.map(_DetailAttachment.fromNoteMedia).toList();
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
                : UiStrings.noteDetailLoadFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
        _loadErrorMessage = UiStrings.noteDetailLoadFailed;
      });
    }
  }

  Future<void> _togglePin() async {
    if (_actionsBusy || _note == null) return;
    setState(() => _pinning = true);
    try {
      final response =
          await ref.read(notesServiceProvider).pinNote(widget.noteId);
      if (!mounted) return;
      if (!response.isSuccess || response.data == null) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.noteDetailNetworkError,
        );
        return;
      }
      setState(() => _note = response.data);
      if (response.message.isNotEmpty) {
        $message.success(message: response.message);
      }
      await ref.read(notesListProvider.notifier).refresh();
    } on DioException catch (error) {
      if (!mounted) return;
      final apiError = error.error;
      $message.error(
        message: apiError is ApiException && apiError.message.isNotEmpty
            ? apiError.message
            : UiStrings.noteDetailNetworkError,
      );
    } finally {
      if (mounted) setState(() => _pinning = false);
    }
  }

  Future<void> _confirmDelete() async {
    if (_actionsBusy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(UiStrings.noteDetailDeleteConfirmTitle),
          content: const Text(UiStrings.noteDetailDeleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(UiStrings.noteDetailCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(UiStrings.noteDetailDelete),
            ),
          ],
        );
      },
    );
    if (confirmed == true) await _delete();
  }

  Future<void> _delete() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    try {
      final response =
          await ref.read(notesServiceProvider).deleteNote(widget.noteId);
      if (!mounted) return;
      if (!response.isSuccess) {
        $message.error(
          message: response.message.isNotEmpty
              ? response.message
              : UiStrings.noteDetailNetworkError,
        );
        return;
      }
      if (response.message.isNotEmpty) {
        $message.success(message: response.message);
      }
      await ref.read(notesListProvider.notifier).refresh();
      if (!mounted) return;
      context.pop();
    } on DioException catch (error) {
      if (!mounted) return;
      final apiError = error.error;
      $message.error(
        message: apiError is ApiException && apiError.message.isNotEmpty
            ? apiError.message
            : UiStrings.noteDetailNetworkError,
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _openEditor() async {
    if (_actionsBusy) return;
    await context.push(AppConstants.noteEditPath(widget.noteId));
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: const CustomAppBar(
          title: UiStrings.noteDetailPageTitle,
          showBack: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadFailed) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: const CustomAppBar(
          title: UiStrings.noteDetailPageTitle,
          showBack: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadErrorMessage ?? UiStrings.noteDetailLoadFailed,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _load,
                  child: const Text(UiStrings.noteDetailRetry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final note = _note!;
    final title = (note.title ?? '').trim();
    final displayTitle =
        title.isEmpty ? UiStrings.noteDetailUntitled : title;
    final isPinned = note.pinnedAt != null;

    final busy = _actionsBusy;
    final actionStyle = theme.textTheme.labelLarge?.copyWith(
      color: busy
          ? colorScheme.onSurfaceVariant
          : colorScheme.primary,
      fontWeight: FontWeight.w400,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: UiStrings.noteDetailPageTitle,
        showBack: true,
        actions: [
          TextButton(
            onPressed: busy ? null : _togglePin,
            child: Text(
              isPinned
                  ? UiStrings.noteDetailUnpin
                  : UiStrings.noteDetailPin,
              style: actionStyle,
            ),
          ),
          TextButton(
            onPressed: busy ? null : _confirmDelete,
            child: Text(
              UiStrings.noteDetailDelete,
              style: actionStyle,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        Text(
                          formatNoteDetailTime(note.updatedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isPinned) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              UiStrings.noteDetailPinnedBadge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Text(
                      displayTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: quill.QuillEditor.basic(
                      controller: _quillController,
                      focusNode: _editorFocusNode,
                      scrollController: _scrollController,
                      config: const quill.QuillEditorConfig(
                        scrollable: false,
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                        showCursor: false,
                        enableInteractiveSelection: true,
                      ),
                    ),
                  ),
                  if (_attachments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: _buildAttachmentsSection(theme, colorScheme),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: OutlinedButton(
                onPressed: busy ? null : _openEditor,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorScheme.surface,
                ),
                child: const Text(UiStrings.noteDetailEdit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
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
            const SizedBox(width: 8),
            _AttachmentCountBadge(count: _attachments.length),
          ],
        ),
        const SizedBox(height: 14),
        for (final attachment in _attachments) ...[
          _DetailAttachmentCard(attachment: attachment),
          const SizedBox(height: 10),
        ],
      ],
    );
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

class _DetailAttachmentCard extends StatelessWidget {
  const _DetailAttachmentCard({required this.attachment});

  final _DetailAttachment attachment;

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
          ],
        ),
      ),
    );
  }
}

class _DetailAttachment {
  const _DetailAttachment({
    required this.name,
    required this.size,
    this.extension,
  });

  factory _DetailAttachment.fromNoteMedia(NoteMediaItemDto media) {
    final key = media.qiniuKey ?? '';
    final name = key.split('/').last;
    final extension = name.contains('.') ? name.split('.').last : null;
    return _DetailAttachment(
      name: name.isEmpty ? media.id : name,
      size: media.fileSize ?? 0,
      extension: extension,
    );
  }

  final String name;
  final int size;
  final String? extension;

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
