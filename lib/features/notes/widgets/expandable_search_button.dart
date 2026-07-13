import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';

/// Compact search control that expands into a keyword field.
///
/// Collapsed: square icon button. Expanded: animated field with search submit
/// and optional clear/collapse. Parent owns [controller] and search side effects.
class ExpandableSearchButton extends StatefulWidget {
  const ExpandableSearchButton({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onCollapsedClear,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCollapsedClear;

  @override
  State<ExpandableSearchButton> createState() => _ExpandableSearchButtonState();
}

class _ExpandableSearchButtonState extends State<ExpandableSearchButton> {
  static const double _collapsedSize = 40;
  static const double _maxExpandedWidth = 220;

  bool _expanded = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _collapseAndClear() {
    final hadKeyword = widget.controller.text.trim().isNotEmpty;
    widget.controller.clear();
    setState(() => _expanded = false);
    _focusNode.unfocus();
    if (hadKeyword) {
      widget.onCollapsedClear();
    }
  }

  double _widthForConstraints(BoxConstraints constraints) {
    if (!_expanded) return _collapsedSize;

    final maxWidth = constraints.maxWidth;
    if (!maxWidth.isFinite) return _maxExpandedWidth;

    return maxWidth.clamp(_collapsedSize, _maxExpandedWidth);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: _widthForConstraints(constraints),
          height: _collapsedSize,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: _expanded
              ? _buildExpanded(colorScheme)
              : _buildCollapsed(colorScheme),
        );
      },
    );
  }

  Widget _buildCollapsed(ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _expand,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildExpanded(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => widget.onSubmit(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
            decoration: InputDecoration(
              isDense: true,
              hintText: UiStrings.searchNotesHint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.primary,
          ),
          onPressed: widget.onSubmit,
          tooltip: UiStrings.searchNotes,
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(
            Icons.close,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: _collapseAndClear,
          tooltip: UiStrings.cancel,
        ),
      ],
    );
  }
}
