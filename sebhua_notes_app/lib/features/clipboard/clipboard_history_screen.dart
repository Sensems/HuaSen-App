import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_bottom_nav.dart';

/// The type of content stored in a clipboard entry.
enum _ClipboardType { text, image, file }

/// Placeholder clipboard entry data.
class _ClipboardEntry {
  const _ClipboardEntry({
    required this.id,
    required this.type,
    required this.preview,
    required this.timestamp,
    this.isPinned = false,
  });

  final String id;
  final _ClipboardType type;
  final String preview;
  final String timestamp;
  final bool isPinned;
}

/// Screen showing a list of clipboard history entries.
///
/// Each entry shows a type-specific icon (text/image/file), a content
/// preview, a timestamp, and a pin toggle action.
class ClipboardHistoryScreen extends StatefulWidget {
  const ClipboardHistoryScreen({super.key});

  @override
  State<ClipboardHistoryScreen> createState() =>
      _ClipboardHistoryScreenState();
}

class _ClipboardHistoryScreenState extends State<ClipboardHistoryScreen> {
  /// Mock data — replaced by a provider in a later task.
  final List<_ClipboardEntry> _entries = [
    const _ClipboardEntry(
      id: '1',
      type: _ClipboardType.text,
      preview: 'flutter_riverpod: ^2.6.1',
      timestamp: '5 min ago',
      isPinned: true,
    ),
    const _ClipboardEntry(
      id: '2',
      type: _ClipboardType.text,
      preview: 'The quick brown fox jumps over the lazy dog.',
      timestamp: '1 hour ago',
    ),
    const _ClipboardEntry(
      id: '3',
      type: _ClipboardType.image,
      preview: 'screenshot_2025_01_15.png  (1920×1080)',
      timestamp: '3 hours ago',
    ),
    const _ClipboardEntry(
      id: '4',
      type: _ClipboardType.file,
      preview: 'design_specs.pdf  (2.4 MB)',
      timestamp: 'Yesterday',
    ),
    const _ClipboardEntry(
      id: '5',
      type: _ClipboardType.text,
      preview: 'https://docs.flutter.dev/cookbook',
      timestamp: '2 days ago',
    ),
  ];

  bool get _isWide => MediaQuery.of(context).size.width >= 600;

  void _togglePin(String id) {
    // Placeholder — will update state via provider in a later task.
    setState(() {
      final index = _entries.indexWhere((e) => e.id == id);
      if (index != -1) {
        final entry = _entries[index];
        _entries[index] = _ClipboardEntry(
          id: entry.id,
          type: entry.type,
          preview: entry.preview,
          timestamp: entry.timestamp,
          isPinned: !entry.isPinned,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sort: pinned first, then by original order.
    final sorted = List.of(_entries)
      ..sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });

    return Scaffold(
      appBar: CustomAppBar(
        title: UiStrings.clipboardHistory,
        showBack: !_isWide,
      ),
      body: sorted.isEmpty ? _buildEmptyState() : _buildList(sorted),
      bottomNavigationBar: _isWide
          ? null
          : CustomBottomNav(
              currentIndex: 1,
              items: const [
                CustomNavItem(
                  icon: Icons.note_outlined,
                  activeIcon: Icons.note,
                  label: UiStrings.navNotes,
                ),
                CustomNavItem(
                  icon: Icons.content_copy_outlined,
                  activeIcon: Icons.content_copy,
                  label: UiStrings.navClipboard,
                ),
                CustomNavItem(
                  icon: Icons.drafts_outlined,
                  activeIcon: Icons.drafts,
                  label: UiStrings.navDrafts,
                ),
                CustomNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: UiStrings.navSettings,
                ),
              ],
              onTap: _onNavTap,
            ),
    );
  }

  Widget _buildList(List<_ClipboardEntry> entries) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final icon = _iconForType(entry.type);
        final iconColor = _colorForType(entry.type, colorScheme);

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            title: Text(
              entry.preview,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.timestamp,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                entry.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: entry.isPinned
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              onPressed: () => _togglePin(entry.id),
              tooltip: entry.isPinned ? UiStrings.unpin : UiStrings.pin,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.content_copy,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            UiStrings.noClipboardEntries,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            UiStrings.noClipboardHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(_ClipboardType type) {
    switch (type) {
      case _ClipboardType.text:
        return Icons.text_snippet_outlined;
      case _ClipboardType.image:
        return Icons.image_outlined;
      case _ClipboardType.file:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _colorForType(_ClipboardType type, ColorScheme colorScheme) {
    switch (type) {
      case _ClipboardType.text:
        return colorScheme.primary;
      case _ClipboardType.image:
        return colorScheme.tertiary;
      case _ClipboardType.file:
        return colorScheme.secondary;
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 2:
        context.go('/drafts');
      case 3:
        context.go('/settings');
    }
  }
}