# lib/features/settings

Application settings and preferences feature.

## Responsibilities

- Theme selection (light/dark/system)
- Sync configuration (server URL, sync intervals)
- WeChat integration settings
- Storage management and cleanup
- About / version info

## Internal Structure

- `data/` - Settings data source (SharedPreferences / Drift)
- `domain/` - Settings entity, repository interface
- `presentation/` - Settings page, preference widgets, providers