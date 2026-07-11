# lib/ui/theme

Application design system: colors, typography, spacing, and shape tokens.

## Contents

- **app_colors.dart** - Color palette and semantic color definitions
- **app_typography.dart** - Font families, text styles, font scale
- **app_spacing.dart** - Spacing scale (4px base grid)
- **app_shapes.dart** - Border radius and shape definitions
- **app_theme.dart** - ThemeData assembly (light and dark themes)

## Design Tokens

All visual properties (color, size, spacing, radius) should reference tokens
defined here. Never hardcode hex colors or arbitrary pixel values in widgets.