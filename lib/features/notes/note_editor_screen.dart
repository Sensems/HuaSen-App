import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_button.dart';
import '../../ui/components/custom_input.dart';

/// Placeholder screen for editing or creating a note.
///
/// Shows a title input, a placeholder area for the rich text editor, and a
/// placeholder area for media attachments. The note [id] is received from
/// the route parameter — `new` indicates a new note.
class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    super.key,
    required this.noteId,
  });

  /// The note identifier from the route path. Use `'new'` for creation.
  final String noteId;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get _isNew => widget.noteId == 'new';
  bool get _isWide => MediaQuery.of(context).size.width >= 600;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isNew ? UiStrings.createNote : UiStrings.navNotes,
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _onDelete,
            tooltip: UiStrings.deleteNote,
          ),
          const SizedBox(width: 4),
          CustomButton(
            label: UiStrings.saveNote,
            onPressed: _onSave,
          ),
        ],
      ),
      body: _isWide ? _buildWideBody() : _buildMobileBody(),
    );
  }

  Widget _buildMobileBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInput(
            controller: _titleController,
            hint: UiStrings.noteTitleHint,
            autofocus: _isNew,
          ),
          const SizedBox(height: 16),
          _buildEditorPlaceholder(),
          const SizedBox(height: 24),
          _buildMediaPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildWideBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Editor pane
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInput(
                  controller: _titleController,
                  hint: UiStrings.noteTitleHint,
                  autofocus: _isNew,
                ),
                const SizedBox(height: 16),
                _buildEditorPlaceholder(),
              ],
            ),
          ),
        ),
        // Media pane
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildMediaPlaceholder(),
          ),
        ),
      ],
    );
  }

  /// Placeholder for the rich text editor that will be implemented later.
  Widget _buildEditorPlaceholder() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: CustomInput(
        controller: _contentController,
        hint: UiStrings.noteContentHint,
        maxLines: null,
      ),
    );
  }

  /// Placeholder for the media attachments section.
  Widget _buildMediaPlaceholder() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                UiStrings.mediaAttachments,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                Text(
                  UiStrings.mediaAttachmentsHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: UiStrings.attachMedia,
                  icon: Icons.add,
                  variant: CustomButtonVariant.secondary,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    // Placeholder — will call the repository in a later task.
    context.pop();
  }

  void _onDelete() {
    // Placeholder — will call the repository in a later task.
    context.pop();
  }
}