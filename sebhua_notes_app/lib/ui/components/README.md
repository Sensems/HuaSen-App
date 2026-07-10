# lib/ui/components

Reusable, feature-agnostic UI components.

## Guidelines

- Components must not import from any `lib/features/` module
- Components should accept configuration via constructor parameters
- Use design tokens from `lib/ui/theme/` for colors, spacing, typography
- Prefer composable widgets over monolithic ones

## Examples

- AppButton - Primary/secondary/outline button variants
- AppCard - Card container with consistent elevation and radius
- AppTextField - Text input with validation support
- AppDialog - Dialog wrapper with consistent styling
- LoadingIndicator - Loading spinner / overlay
- EmptyState - Empty placeholder with icon and message