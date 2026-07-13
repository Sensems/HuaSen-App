import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../../../data/models/note_dtos.dart';
import '../note_time_format.dart';

/// Presentational card for one note in the list.
///
/// When [showPinChrome] is true, shows a left primary bar and pin icon
/// (placeholder pinned UI only — not driven by API).
class NoteListCard extends StatelessWidget {
  const NoteListCard({
    super.key,
    required this.note,
    required this.onTap,
    this.showPinChrome = false,
  });

  final NoteDetailDto note;
  final VoidCallback onTap;
  final bool showPinChrome;

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showPinChrome)
                    Container(
                      width: 4,
                      color: colorScheme.primary,
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (showPinChrome) ...[
                                Icon(
                                  Icons.push_pin,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (preview.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              preview,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  timestamp,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.75),
                                  ),
                                ),
                              ),
                              if (hasMedia)
                                Icon(
                                  Icons.image_outlined,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
