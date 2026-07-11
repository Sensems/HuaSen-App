# lib/core

Shared infrastructure and utilities used across all features.

## Contents

- **constants/** - Application-wide constants (API endpoints, storage keys, etc.)
- **errors/** - Failure classes, error handling utilities
- **network/** - Dio HTTP client configuration, interceptors
- **storage/** - Local storage helpers, preferences
- **utils/** - Helper functions, extensions, formatters
- **theme/** - App-wide theme data (colors, typography, spacing tokens)

This layer has no dependencies on features or data layers. It provides the
foundation that features build upon.