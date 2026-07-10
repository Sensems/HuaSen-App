import 'package:flutter/material.dart';

/// Button visual style variants.
enum CustomButtonVariant {
  /// Filled button using the primary color — used for main actions.
  primary,

  /// Filled button using a muted surface color — used for secondary actions.
  secondary,

  /// Transparent button with no background — used for tertiary actions.
  ghost,
}

/// A reusable, theme-aware button widget.
///
/// Supports three visual variants ([CustomButtonVariant.primary],
/// [secondary], [ghost]), a [loading] state that shows a spinner, and a
/// [disabled] state that dims the button and ignores taps.
///
/// All colors are derived from [Theme.of] so the button automatically
/// adapts to light/dark themes.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.expanded = false,
  });

  /// The text displayed on the button.
  final String label;

  /// Called when the button is tapped. If null or [disabled] is true the
  /// button renders in a non-interactive state.
  final VoidCallback? onPressed;

  /// Visual style of the button.
  final CustomButtonVariant variant;

  /// When true a circular progress indicator replaces the label and taps
  /// are ignored.
  final bool loading;

  /// When true the button renders as non-interactive regardless of
  /// [onPressed].
  final bool disabled;

  /// Optional icon shown to the left of the label.
  final IconData? icon;

  /// When true the button expands to fill available width.
  final bool expanded;

  bool get _isInteractive => onPressed != null && !loading && !disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (backgroundColor, foregroundColor, borderColor) = _resolveStyle(
      colorScheme,
    );

    return Opacity(
      opacity: _isInteractive ? 1.0 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isInteractive ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: BoxConstraints(
              minWidth: expanded ? double.infinity : 0,
            ),
            padding: expanded
                ? const EdgeInsets.symmetric(horizontal: 24, vertical: 14)
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
              boxShadow: variant == CustomButtonVariant.primary &&
                      _isInteractive
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: _buildContent(context, foregroundColor),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color foregroundColor) {
    if (loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(
        color: foregroundColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  (Color, Color, Color?) _resolveStyle(ColorScheme colorScheme) {
    switch (variant) {
      case CustomButtonVariant.primary:
        return (colorScheme.primary, colorScheme.onPrimary, null);
      case CustomButtonVariant.secondary:
        return (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurface,
          null,
        );
      case CustomButtonVariant.ghost:
        return (Colors.transparent, colorScheme.onSurface, colorScheme.outline);
    }
  }
}