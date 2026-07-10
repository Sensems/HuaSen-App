import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_bottom_nav.dart';
import '../../ui/components/custom_button.dart';

/// Placeholder draft note data.
class _DraftItem {
  const _DraftItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.timestamp,
  });

  final String id;
  final String title;
  final String preview;
  final String timestamp;
}

/// Screen showing a list of WeChat draft notes.
///
/// Each draft has a "Convert to Note" action that will move it to the main
/// notes collection (placeholder for now).
class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  /// Mock data — replaced by a provider in a later task.
  final List<_DraftItem> _drafts = [
    const _DraftItem(
      id: 'd1',
      title: 'Reply to Team Group',
      preview:
          'Thanks everyone for the update. I will review the changes and get back by tomorrow afternoon.',
      timestamp: '30 min ago',
    ),
    const _DraftItem(
      id: 'd2',
      title: 'Project Update',
      preview:
          'The sprint is on track. We completed the UI components and are starting on the data layer.',
      timestamp: '2 hours ago',
    ),
    const _DraftItem(
      id: 'd3',
      title: 'Meeting Follow-up',
      preview:
          'Action items: 1. Send the design specs. 2. Schedule a review session. 3. Update the roadmap.',
      timestamp: 'Yesterday',
    ),
  ];

  bool get _isWide => MediaQuery.of(context).size.width >= 600;

  void _convertToNote(_DraftItem draft) {
    // Placeholder — will call the repository to convert the draft.
    setState(() {
      _drafts.removeWhere((d) => d.id == draft.id);
    });

    if (!mounted) return;

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${draft.title} → ${UiStrings.navNotes}',
          style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: UiStrings.wechatDrafts,
        showBack: !_isWide,
      ),
      body: _drafts.isEmpty ? _buildEmptyState() : _buildList(),
      bottomNavigationBar: _isWide
          ? null
          : CustomBottomNav(
              currentIndex: 2,
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

  Widget _buildList() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _drafts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final draft = _drafts[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      UiStrings.draft,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color:
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    draft.timestamp,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                draft.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                draft.preview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  label: UiStrings.convertToNote,
                  icon: Icons.swap_horiz,
                  variant: CustomButtonVariant.ghost,
                  onPressed: () => _convertToNote(draft),
                ),
              ),
            ],
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
            Icons.drafts_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            UiStrings.noDrafts,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            UiStrings.noDraftsHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/clipboard');
      case 3:
        context.go('/settings');
    }
  }
}