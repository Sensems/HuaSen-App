# lib/features/wechat

WeChat draft synchronization feature.

## Responsibilities

- Sync note content as WeChat drafts
- Manage WeChat authentication and session
- Handle draft creation, update, and deletion
- Bridge between local notes and WeChat draft API

## Internal Structure

- `data/` - WeChat API client (Dio), draft DTOs, repository implementation
- `domain/` - WeChat draft entity, repository interface, use cases
- `presentation/` - WeChat sync status widget, providers