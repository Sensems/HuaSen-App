import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../notes_list_state.dart';

/// Text filter tabs for the notes list: 全部 / 置顶 / 最近, plus trailing filter icon.
class NotesFilterTabs extends StatelessWidget {
  const NotesFilterTabs({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onFilterTap,
    this.hasActiveFilter = false,
  });

  final NotesFilterTab value;
  final ValueChanged<NotesFilterTab> onChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilter;

  static const _tabs = <(NotesFilterTab, String)>[
    (NotesFilterTab.all, UiStrings.notesFilterAll),
    (NotesFilterTab.pinned, UiStrings.notesFilterPinned),
    (NotesFilterTab.recent, UiStrings.notesFilterRecent),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        for (final (tab, label) in _tabs) ...[
          if (tab != NotesFilterTab.all) const SizedBox(width: 20),
          _FilterTab(
            label: label,
            selected: value == tab,
            onTap: () => onChanged(tab),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
        const Spacer(),
        IconButton(
          onPressed: onFilterTap,
          tooltip: UiStrings.notesCategoryTagFilterTitle,
          visualDensity: VisualDensity.compact,
          icon: Badge(
            isLabelVisible: hasActiveFilter,
            smallSize: 8,
            child: Icon(
              Icons.filter_list,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              width: 28,
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
