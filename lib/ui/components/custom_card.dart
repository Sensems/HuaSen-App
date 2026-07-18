import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A reusable, theme-aware card for displaying a note summary.
///
/// Shows a [title], a content [preview] capped at [maxPreviewLines] lines,
/// a [timestamp], and an optional pin icon when [isPinned] is true.
///
/// All colors are derived from [Theme.of] so the card adapts to light/dark
/// themes automatically.
class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.title,
    required this.preview,
    required this.timestamp,
    this.isPinned = false,
    this.onTap,
    this.trailing,
    this.maxPreviewLines = 2,
  });

  /// Note title displayed in bold.
  final String title;

  /// Short content preview shown below the title.
  final String preview;

  /// Human-readable timestamp (e.g. "2 hours ago").
  final String timestamp;

  /// When true a pin icon is shown in the top-right corner.
  final bool isPinned;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Optional widget shown at the bottom-right of the card (e.g. action
  /// buttons).
  final Widget? trailing;

  /// Maximum number of lines for [preview] before truncation.
  final int maxPreviewLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.elevatedSurfaceOf(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title row with pin icon ---
              Row(
                children: [
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
                  if (isPinned) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.push_pin,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // --- Content preview ---
              Text(
                preview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: maxPreviewLines,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // --- Metadata row ---
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timestamp,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  ?trailing,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}