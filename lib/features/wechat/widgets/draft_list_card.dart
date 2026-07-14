import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../../../data/models/note_dtos.dart';
import '../../../ui/theme/app_colors.dart';
import '../../notes/note_time_format.dart';

Color _elevatedCardSurface(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.light
      ? AppColors.lightSurface
      : AppColors.darkSurface;
}

class DraftListCard extends StatelessWidget {
  const DraftListCard({
    super.key,
    required this.note,
    required this.onOpen,
    required this.onDelete,
  });

  final NoteDetailDto note;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  static String _previewText(String? content) {
    if (content == null || content.isEmpty) return '';
    return content.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = (note.title?.trim().isNotEmpty ?? false)
        ? note.title!.trim()
        : UiStrings.notesUntitled;
    final preview = _previewText(note.content);
    final timestamp = formatNoteListTime(note.updatedAt, note.createdAt);
    final hasMedia = note.mediaIds?.isNotEmpty ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: _elevatedCardSurface(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.mark_chat_unread,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timestamp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                if (hasMedia) ...[
                  const SizedBox(height: 10),
                  Container(
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      UiStrings.draftsMediaPlaceholder,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: onOpen,
                        child: const Text(UiStrings.draftsComplete),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDelete,
                        child: const Text(UiStrings.draftsDelete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
