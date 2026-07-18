import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../../../data/models/note_dtos.dart';
import '../../../ui/theme/app_colors.dart';
import '../note_content_preview.dart';
import '../note_file_type_style.dart';
import '../note_time_format.dart';

Color _elevatedCardSurface(BuildContext context) =>
    AppColors.elevatedSurfaceOf(context);

/// Presentational card for one note in the list.
///
/// When [showPinChrome] is true, shows a left primary bar and pin icon
/// (driven by [NoteDetailDto.pinnedAt]).
class NoteListCard extends StatelessWidget {
  const NoteListCard({
    super.key,
    required this.note,
    this.media = const [],
    required this.onTap,
    this.showPinChrome = false,
  });

  final NoteDetailDto note;
  final List<NoteMediaItemDto> media;
  final VoidCallback onTap;
  final bool showPinChrome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = (note.title?.trim().isNotEmpty ?? false)
        ? note.title!.trim()
        : UiStrings.notesUntitled;
    final preview = plainTextPreviewFromNoteContent(note.content);
    final timestamp = formatNoteListTime(note.updatedAt, note.createdAt);
    final styles = noteFileTypeStylesForList(
      media: media,
      mediaIds: note.mediaIds,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (styles.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final s in styles.take(6))
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Icon(
                                          s.icon,
                                          size: 16,
                                          color: s.color,
                                        ),
                                      ),
                                    if (styles.length > 6)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          '+${styles.length - 6}',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.75),
                                          ),
                                        ),
                                      ),
                                  ],
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
