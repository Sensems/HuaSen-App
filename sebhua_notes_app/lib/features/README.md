# lib/features

Feature modules following a feature-first architecture. Each feature is
self-contained with its own data, domain, and presentation layers.

## Feature Modules

- **notes/** - Mixed notes (text + media) creation, editing, and management
- **clipboard/** - Cross-device clipboard sync via WebSocket
- **settings/** - App settings, preferences, and configuration
- **wechat/** - WeChat draft synchronization

Each feature folder typically contains:
- `data/` - Data sources, DTOs, repository implementations
- `domain/` - Entities, repository interfaces, use cases
- `presentation/` - Widgets, pages, providers (Riverpod)