# lib/features/clipboard

Cross-device clipboard sync feature.

## Responsibilities

- Monitor system clipboard via super_clipboard
- Send clipboard updates to sync server over WebSocket
- Receive clipboard updates from other devices
- Handle rich text, images, and file clipboard formats

## Internal Structure

- `data/` - Clipboard sync data sources, WebSocket connection management
- `domain/` - Clipboard entry entity, sync repository interface
- `presentation/` - Clipboard sync status widget, providers