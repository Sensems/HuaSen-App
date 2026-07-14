import 'package:flutter/material.dart';

import '../../../core/constants/ui_strings.dart';
import '../../../ui/theme/app_colors.dart';

Color _elevatedSearchFill(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.light
      ? AppColors.lightSurface
      : AppColors.darkSurface;
}

/// Compact search control that expands into a keyword field.
///
/// Collapsed: square icon button. Expanded: animated field with search submit.
/// Empty + unfocused collapses; non-empty unfocused stays expanded.
/// Parent owns [controller] and search side effects.
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
  static const double _expandedRightInset = 12;

  bool _expanded = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus || !_expanded) return;
    if (widget.controller.text.trim().isNotEmpty) return;

    setState(() => _expanded = false);
    // clearSearch() no-ops when keyword is already empty.
    widget.onCollapsedClear();
  }

  void _expand() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
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
            color: _elevatedSearchFill(context),
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
    return Padding(
      padding: const EdgeInsets.only(right: _expandedRightInset),
      child: Row(
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
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
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
        ],
      ),
    );
  }
}
