# Note Editor UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current note editor placeholder with a `flutter_quill` based editor UI and local-only interactions matching the approved mockup direction.

**Architecture:** Keep the implementation feature-local and page-owned for this UI-only iteration. `NoteEditorScreen` owns title, Quill document, dirty state, file picker state, and local attachment state; no API service, repository, Drift, or generated code is introduced. Shared copy lives in `UiStrings`; visual styling follows the existing theme and `ColorScheme`.

**Tech Stack:** Flutter Material, `flutter_quill` 11.5.1, `file_picker` 11.0.2, `go_router`, `tolyui_message`, existing app theme/components.

## Global Constraints

- Work directly on the current `master` workspace. Do not create branches or worktrees.
- Do not commit unless the user explicitly asks.
- Do not call `NotesService`, `StorageService`, repositories, Drift, or any backend API in this iteration.
- Do not add new dependencies; use `flutter_quill`, `file_picker`, and `tolyui_message` already in `pubspec.yaml`.
- Use `ColorScheme.primary` / theme colors for coral accents; do not introduce hardcoded brand hex values in widgets.
- Use `tolyui_message` for user feedback.
- Prefer manual QA for this phase; do not add automated tests unless the user asks.
- Run `flutter analyze` before claiming implementation is complete.

---

## File Structure

Modify only these files unless analysis shows a compile-time need for a small helper:

| File | Responsibility |
|------|----------------|
| `lib/core/constants/ui_strings.dart` | Add Chinese editor copy for the approved UI and local feedback messages |
| `lib/features/notes/note_editor_screen.dart` | Replace the placeholder title/body/attachment UI with page-owned Quill editor, compact toolbar, local file attachments, and local actions |

Keep attachment model/widgets private to `note_editor_screen.dart` for this iteration. If the file becomes hard to review, split only attachment card widgets into `lib/features/notes/widgets/` during Task 3, but do not introduce new domain/data layers.

## Task 1: Editor Copy And Screen Shell

**Files:**
- Modify: `lib/core/constants/ui_strings.dart`
- Modify: `lib/features/notes/note_editor_screen.dart`

**Interfaces:**
- Produces: Editor-specific `UiStrings` constants consumed by later tasks.
- Produces: A mobile-first screen shell with custom top bar, title input, editor slot, attachment slot, and bottom action slot.
- Consumes: Existing `NoteEditorScreen(noteId: ...)` route contract.

- [ ] **Step 1: Add editor strings**

In `lib/core/constants/ui_strings.dart`, replace the current note editor constants block with this expanded block. Keep the surrounding sections unchanged.

```dart
  // --- Note editor screen ---
  static const String noteEditorBack = '返回';
  static const String noteEditorSave = '保存';
  static const String noteEditorTitleHint = 'Q3 产品规划会议纪要';
  static const String noteEditorContentHint = '开始记录...';
  static const String noteEditorAttachments = '附件';
  static const String noteEditorAttach = '+ 添加附件';
  static const String noteEditorSyncClipboard = '同步至剪贴板';
  static const String noteEditorSavedLocal = '已保存到本地草稿，接口接入后将同步到云端';
  static const String noteEditorClipboardDeferred = '剪贴板同步将在接口接入阶段启用';
  static const String noteEditorPickFileFailed = '选择附件失败，请重试';
  static const String noteEditorLinkTitle = '添加链接';
  static const String noteEditorLinkHint = 'https://example.com';
  static const String noteEditorLinkEmpty = '请输入链接地址';
  static const String noteTitleHint = 'Note title';
  static const String noteContentHint = 'Start writing...';
  static const String mediaAttachments = 'Media Attachments';
  static const String mediaAttachmentsHint =
      'Photos, images, and files will appear here';
  static const String attachMedia = 'Attach Media';
  static const String saveNote = 'Save';
  static const String deleteNote = 'Delete';
```

Rationale: keep existing English constants for any current call sites while adding approved Chinese copy for the new editor UI.

- [ ] **Step 2: Replace the scaffold chrome**

In `lib/features/notes/note_editor_screen.dart`, remove `CustomAppBar`, `CustomButton`, and `CustomInput` imports if they are no longer used after this task. Add only the imports needed by the shell now:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
```

Replace the current `build` method with a custom top-bar scaffold:

```dart
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _EditorTopBar(
              onBack: () => context.pop(),
              onSave: _onSave,
            ),
            Expanded(
              child: _isWide ? _buildWideBody() : _buildMobileBody(),
            ),
          ],
        ),
      ),
    );
  }
```

Add the `_EditorTopBar` widget at the bottom of the file:

```dart
class _EditorTopBar extends StatelessWidget {
  const _EditorTopBar({
    required this.onBack,
    required this.onSave,
  });

  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onBack,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: EdgeInsets.zero,
              minimumSize: const Size(52, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text(UiStrings.noteEditorBack),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSave,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text(UiStrings.noteEditorSave),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Replace title input and page skeleton**

Add a title field builder:

```dart
  Widget _buildTitleField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: _titleController,
      autofocus: _isNew,
      maxLines: null,
      decoration: const InputDecoration(
        hintText: UiStrings.noteEditorTitleHint,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        height: 1.2,
      ),
      onChanged: (_) => _markDirty(),
    );
  }
```

Temporarily keep `_buildEditorPlaceholder()` and `_buildMediaPlaceholder()` as slots for Task 2 and Task 3, but update `_buildMobileBody()` and `_buildWideBody()` to use `_buildTitleField()`:

```dart
  Widget _buildMobileBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        _buildTitleField(),
        const SizedBox(height: 16),
        _buildEditorPlaceholder(),
        const SizedBox(height: 22),
        _buildMediaPlaceholder(),
        const SizedBox(height: 28),
        _buildSyncClipboardButton(),
      ],
    );
  }

  Widget _buildWideBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildEditorPlaceholder(),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildMediaPlaceholder(),
              const SizedBox(height: 28),
              _buildSyncClipboardButton(),
            ],
          ),
        ),
      ],
    );
  }
```

Add local action methods:

```dart
  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  Widget _buildSyncClipboardButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: _onSyncClipboard,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(UiStrings.noteEditorSyncClipboard),
      ),
    );
  }

  void _onSave() {
    _isDirty = false;
    $message.success(message: UiStrings.noteEditorSavedLocal);
  }

  void _onSyncClipboard() {
    $message.success(message: UiStrings.noteEditorClipboardDeferred);
  }
```

Declare `_isDirty` in state:

```dart
  var _isDirty = false;
```

Remove `_onDelete()` from the screen once no call site remains.

- [ ] **Step 4: Verify Task 1**

Run:

```bash
flutter analyze
```

Expected: analyzer exits successfully. If it reports unused imports or unused private members, remove or wire those symbols before review.

Do not commit.

## Task 2: Quill Editor And Compact Toolbar

**Files:**
- Modify: `lib/features/notes/note_editor_screen.dart`

**Interfaces:**
- Consumes: Task 1 shell and title field.
- Produces: `_quillController`, `_buildEditorSection()`, `_EditorToolbar`, `_ToolbarButton`, and link dialog behavior.
- Produces: Quill Delta JSON serialization point for the next API wiring phase.

- [ ] **Step 1: Add Quill imports and controller state**

Update imports:

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';
```

Replace `_contentController` with `_quillController`:

```dart
  late final quill.QuillController _quillController;
```

Initialize and dispose it:

```dart
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _quillController = quill.QuillController.basic();
    _quillController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController
      ..removeListener(_markDirty)
      ..dispose();
    super.dispose();
  }
```

Add the serialization helper. It is not sent to the backend yet, but keeps the next phase explicit:

```dart
  String _serializeQuillContent() {
    return jsonEncode(_quillController.document.toDelta().toJson());
  }
```

Update `_onSave()` to exercise serialization without sending it:

```dart
  void _onSave() {
    _serializeQuillContent();
    _isDirty = false;
    $message.success(message: UiStrings.noteEditorSavedLocal);
  }
```

- [ ] **Step 2: Replace editor placeholder with Quill section**

Rename `_buildEditorPlaceholder()` to `_buildEditorSection()` and use it from mobile/wide body.

Use this structure:

```dart
  Widget _buildEditorSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EditorToolbar(
            controller: _quillController,
            onLink: _showLinkDialog,
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 190),
            child: quill.QuillEditor.basic(
              controller: _quillController,
              config: quill.QuillEditorConfig(
                placeholder: UiStrings.noteEditorContentHint,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
```

If `QuillEditorConfig.padding` is not available in the installed version, move padding to a surrounding `Padding` widget and keep `QuillEditorConfig(placeholder: ...)`.

- [ ] **Step 3: Add compact toolbar widget**

Add `_EditorToolbar` and `_ToolbarButton` below `_EditorTopBar`:

```dart
class _EditorToolbar extends StatefulWidget {
  const _EditorToolbar({
    required this.controller,
    required this.onLink,
  });

  final quill.QuillController controller;
  final VoidCallback onLink;

  @override
  State<_EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<_EditorToolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant _EditorToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  bool _isActive(quill.Attribute<dynamic> attribute) {
    return widget.controller
        .getSelectionStyle()
        .attributes
        .containsKey(attribute.key);
  }

  void _toggle(quill.Attribute<dynamic> attribute) {
    final active = _isActive(attribute);
    widget.controller.formatSelection(
      active ? quill.Attribute.clone(attribute, null) : attribute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
            label: 'H',
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
            isActive: _isActive(quill.Attribute.link),
            onPressed: widget.onLink,
          ),
          _ToolbarButton(
            icon: Icons.undo,
            onPressed: widget.controller.hasUndo
                ? widget.controller.undo
                : null,
          ),
        ],
      ),
    );
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
    final foreground = isActive ? colorScheme.primary : colorScheme.onSurface;
    final background = isActive
        ? colorScheme.primary.withValues(alpha: 0.10)
        : colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 36,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outlineVariant,
              ),
            ),
            child: icon != null
                ? Icon(icon, size: 17, color: foreground)
                : Text(
                    label!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                      fontStyle: label == 'I' ? FontStyle.italic : null,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
```

If `hasUndo` is not exposed in `flutter_quill` 11.5.1, always enable the undo button and call `widget.controller.undo()`; analyzer will confirm the available API.

- [ ] **Step 4: Add link dialog**

Add `_showLinkDialog()` to `_NoteEditorScreenState`:

```dart
  Future<void> _showLinkDialog() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(UiStrings.noteEditorLinkTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: UiStrings.noteEditorLinkHint,
            ),
            onSubmitted: (value) {
              final trimmed = value.trim();
              if (trimmed.isNotEmpty) {
                Navigator.of(context).pop(trimmed);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(UiStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isEmpty) {
                  $message.error(message: UiStrings.noteEditorLinkEmpty);
                  return;
                }
                Navigator.of(context).pop(trimmed);
              },
              child: const Text(UiStrings.confirm),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (url == null || url.isEmpty) return;
    _quillController.formatSelection(quill.LinkAttribute(url));
  }
```

If the installed Quill API does not expose `LinkAttribute`, use:

```dart
_quillController.formatSelection(
  quill.Attribute.fromKeyValue('link', url),
);
```

- [ ] **Step 5: Verify Task 2**

Run:

```bash
flutter analyze
```

Expected: analyzer exits successfully. Fix any API mismatches against `flutter_quill` 11.5.1 before review.

Manual check:

1. Open `/note/new`.
2. Type text in the editor.
3. Toggle bold, italic, heading, bullet list, link, and undo.
4. Confirm toolbar active states update for bold/italic/heading/list/link selections where supported.

Do not commit.

## Task 3: Local Attachments And Final Polish

**Files:**
- Modify: `lib/features/notes/note_editor_screen.dart`
- Modify: `lib/core/constants/ui_strings.dart` only if Task 3 discovers one missing copy string

**Interfaces:**
- Consumes: Task 1 shell and Task 2 editor.
- Produces: local `List<_LocalAttachment>`, file picker flow, attachment cards, delete interaction, final manual QA path.

- [ ] **Step 1: Add file picker import and attachment state**

Update imports:

```dart
import 'package:file_picker/file_picker.dart';
```

Add state fields:

```dart
  final List<_LocalAttachment> _attachments = [];
  var _isPickingFile = false;
```

Add the private model at the bottom of the file:

```dart
class _LocalAttachment {
  const _LocalAttachment({
    required this.name,
    required this.size,
    this.extension,
    this.path,
    this.bytes,
  });

  final String name;
  final int size;
  final String? extension;
  final String? path;
  final List<int>? bytes;

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
```

- [ ] **Step 2: Implement file picking**

Add `_pickAttachments()`:

```dart
  Future<void> _pickAttachments() async {
    if (_isPickingFile) return;
    setState(() => _isPickingFile = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;

      final selected = result.files.map((file) {
        return _LocalAttachment(
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
```

Add `_removeAttachment()`:

```dart
  void _removeAttachment(_LocalAttachment attachment) {
    setState(() {
      _attachments.remove(attachment);
      _isDirty = true;
    });
  }
```

- [ ] **Step 3: Replace media placeholder with attachment section**

Rename `_buildMediaPlaceholder()` to `_buildAttachmentSection()` and update mobile/wide bodies to call it.

Use this implementation:

```dart
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
```

- [ ] **Step 4: Add attachment widgets**

Add these private widgets below `_ToolbarButton`:

```dart
class _AttachmentCountBadge extends StatelessWidget {
  const _AttachmentCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      minWidth: 22,
      height: 22,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 7),
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
  const _AttachmentCard({
    required this.attachment,
    required this.onRemove,
  });

  final _LocalAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              attachment.icon,
              size: 18,
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
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
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
            icon: const Icon(Icons.close, size: 18),
            color: colorScheme.onSurfaceVariant,
            tooltip: UiStrings.deleteNote,
          ),
        ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(
          color: colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              UiStrings.noteEditorAttach,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
    );
  }
}
```

Flutter `OutlinedButton` does not support dashed borders. This implementation uses a clean outlined row to keep the scope small and compile-safe. If dashed borders become required later, introduce a small custom painter in a separate UI task.

- [ ] **Step 5: Polish spacing and final state behavior**

Make sure all references are renamed:

```dart
_buildEditorSection()
_buildAttachmentSection()
```

Keep save local-only:

```dart
  void _onSave() {
    _serializeQuillContent();
    _isDirty = false;
    $message.success(message: UiStrings.noteEditorSavedLocal);
  }
```

Keep return direct:

```dart
onBack: () => context.pop(),
```

Do not add an unsaved-changes dialog in this iteration.

- [ ] **Step 6: Verify Task 3**

Run:

```bash
flutter analyze
```

Expected: analyzer exits successfully.

Manual QA:

1. Open `/note/new`.
2. Edit the title.
3. Type text in the Quill editor.
4. Toggle bold, italic, heading, bullet list, link, and undo.
5. Add at least two attachments with `+ 添加附件`.
6. Confirm the attachment count badge changes.
7. Remove one attachment and confirm the badge changes.
8. Tap `保存`; confirm a success toast appears and the page stays open.
9. Tap `同步至剪贴板`; confirm local feedback appears.

Do not commit.

## Self-Review Notes

- Spec coverage: Task 1 covers screen chrome, title, local save/sync feedback, and string constants. Task 2 covers `flutter_quill`, toolbar, link dialog, and Delta JSON serialization reservation. Task 3 covers `file_picker`, attachment cards, deletion, count badge, final polish, and required verification.
- Out-of-scope API work is explicitly excluded in Global Constraints and no task imports or calls `NotesService` / `StorageService`.
- Type boundaries are local and private; the only cross-task shared names are `UiStrings` constants and private `NoteEditorScreen` methods introduced before use.
