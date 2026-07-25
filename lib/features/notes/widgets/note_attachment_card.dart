import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';

/// Shared note attachment row: open on tap, download, optional remove.
///
/// Callbacks are injected by the parent screen — this widget does not import
/// [NoteAttachmentActions].
class NoteAttachmentCard extends StatelessWidget {
  const NoteAttachmentCard({
    super.key,
    required this.name,
    required this.sizeLabel,
    required this.icon,
    required this.onOpen,
    required this.onDownload,
    this.onRemove,
    this.busy = false,
  });

  final String name;
  final String sizeLabel;
  final IconData icon;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback? onRemove;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: busy ? null : onOpen,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
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
                    icon,
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
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sizeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (busy)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    onPressed: onDownload,
                    tooltip: UiStrings.attachmentDownloadTooltip,
                    icon: Icon(
                      Icons.download_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (onRemove != null)
                  IconButton(
                    onPressed: busy ? null : onRemove,
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
        ),
      ),
    );
  }
}
