# lib/data/repositories

Cross-cutting repository implementations shared by multiple features.

## Guidelines

- Each repository implements an interface defined in the domain layer
- Repositories coordinate between local (Drift) and remote (Dio/WebSocket) sources
- Feature-specific repositories stay in `lib/features/<feature>/data/`
- Use Riverpod providers for dependency injection of repositories