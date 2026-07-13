import 'package:flutter/material.dart';

/// A reusable, theme-aware text input field.
///
/// Wraps [TextField] with custom rounded styling derived from [Theme.of].
/// Supports an optional [label], [hint], [prefixIcon], [suffixIcon], and
/// [obscureText] for password fields.
class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.autofocus = false,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Optional label text above the field.
  final String? label;

  /// Placeholder text shown when the field is empty.
  final String? hint;

  /// Icon shown inside the field on the left.
  final IconData? prefixIcon;

  /// Widget shown inside the field on the right (e.g. a clear button).
  final Widget? suffixIcon;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Whether to hide the text (for passwords).
  final bool obscureText;

  /// Whether the field is interactive.
  final bool enabled;

  /// Maximum number of lines. Use null for a growing multi-line field.
  final int? maxLines;

  /// Keyboard type for the field.
  final TextInputType? keyboardType;

  /// Whether to autofocus the field on creation.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.4),
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: 2,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          autofocus: autofocus,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: colorScheme.onSurfaceVariant)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ??
                colorScheme.surfaceContainerLow,
            enabledBorder: inputBorder,
            focusedBorder: focusedBorder,
            disabledBorder: inputBorder,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}