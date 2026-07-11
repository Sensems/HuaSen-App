# lib/features/notes

Mixed notes feature: rich text (via FlutterQuill) with embedded media.

## Responsibilities

- Create, edit, delete, and organize notes
- Support rich text editing with Quill Delta format
- Embed images, audio, and other media in notes
- Persist notes locally via Drift database
- Sync notes across devices

## Internal Structure

- `data/` - Note DTOs, Drift table definitions, repository implementation
- `domain/` - Note entity, repository interface, use cases
- `presentation/` - Note editor page, note list page, providers