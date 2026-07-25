### Task 3: Tab-row filter icon + screen wiring

**Files:**
- Modify: `lib/features/notes/widgets/notes_filter_tabs.dart`
- Modify: `lib/features/notes/notes_list_screen.dart`

**Interfaces:**
- Consumes: `showNotesFilterSheet`, `NotesListNotifier.setCategoryTagFilter`, `state.hasCategoryTagFilter`, `state.categoryId`, `state.tagIds`
- Produces: Tab row trailing filter icon with badge; confirm/clear apply filters

- [ ] **Step 1: Extend `NotesFilterTabs`**

Replace `lib/features/notes/widgets/notes_filter_tabs.dart` with:

```dart
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
```

- [ ] **Step 2: Wire `NotesListScreen`**

In `lib/features/notes/notes_list_screen.dart`:

1. Import the sheet:

```dart
import 'widgets/notes_filter_sheet.dart';
```

2. Add handler on `_NotesListScreenState`:

```dart
  Future<void> _onCategoryTagFilterTap() async {
    final state = ref.read(notesListProvider);
    final result = await showNotesFilterSheet(
      context,
      initialCategoryId: state.categoryId,
      initialTagIds: state.tagIds,
    );
    if (!mounted || result == null) return;
    await ref.read(notesListProvider.notifier).setCategoryTagFilter(
          categoryId: result.categoryId,
          tagIds: result.tagIds,
        );
  }
```

3. Update the `NotesFilterTabs` call site:

```dart
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
              child: NotesFilterTabs(
                value: state.filterTab,
                onChanged: notifier.setFilter,
                onFilterTap: _onCategoryTagFilterTap,
                hasActiveFilter: state.hasCategoryTagFilter,
              ),
            ),
```

(Right padding 12 keeps the icon from hugging the edge; left stays 20.)

- [ ] **Step 3: Verify analyze**

Run:

```bash
flutter analyze lib/features/notes/widgets/notes_filter_tabs.dart lib/features/notes/notes_list_screen.dart lib/features/notes/widgets/notes_filter_sheet.dart
```

Expected: No issues.

- [ ] **Step 4: Commit (only if user asked to commit)**

```bash
git add lib/features/notes/widgets/notes_filter_tabs.dart lib/features/notes/notes_list_screen.dart
git commit -m "feat: wire notes list filter icon and sheet"
```

---
