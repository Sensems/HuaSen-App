import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../drafts_list_state.dart';

class DraftsFilterChips extends StatelessWidget {
  const DraftsFilterChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DraftsFilter value;
  final ValueChanged<DraftsFilter> onChanged;

  static const _chips = <(DraftsFilter, String)>[
    (DraftsFilter.all, UiStrings.draftsFilterAll),
    (DraftsFilter.text, UiStrings.draftsFilterText),
    (DraftsFilter.image, UiStrings.draftsFilterImage),
    (DraftsFilter.audio, UiStrings.draftsFilterAudio),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _Chip(
              label: _chips[i].$2,
              selected: value == _chips[i].$1,
              onTap: () => onChanged(_chips[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? colorScheme.primary : colorScheme.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
