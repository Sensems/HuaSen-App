import 'package:flutter/material.dart';

/// A reusable, theme-aware app bar.
///
/// Unlike the default Material [AppBar], this widget uses a custom layout
/// with rounded bottom corners and theme-derived colors for a premium
/// productivity-app feel.
///
/// Supports an optional back button ([showBack]), a [title], and a list of
/// [actions] shown on the right.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBack = false,
    this.centerTitle = false,
    this.bottom,
  });

  static const double _toolbarHeight = 60;
  static const double _bottomBorderWidth = 1;

  /// Title text. Use null for a title widget if more control is needed.
  final String? title;

  /// Action widgets shown on the right side.
  final List<Widget>? actions;

  /// When true a back button is shown on the left.
  final bool showBack;

  /// Whether to center the title.
  final bool centerTitle;

  /// Optional bottom widget (e.g. a search bar or tab bar).
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    // Include the bottom border — BoxDecoration borders consume layout space
    // and otherwise cause a 1px "BOTTOM OVERFLOWED" stripe under the bar.
    return Size.fromHeight(
      _toolbarHeight + _bottomBorderWidth + bottomHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              width: _bottomBorderWidth,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _toolbarHeight,
              child: NavigationToolbar(
                leading: showBack
                    ? BackButton(
                        color: colorScheme.onSurface,
                        onPressed: () => _goBack(context),
                      )
                    : null,
                middle: title != null
                    ? Text(
                        title!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      )
                    : null,
                trailing: actions != null
                    ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                    : null,
                centerMiddle: centerTitle,
              ),
            ),
            ?bottom,
          ],
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}