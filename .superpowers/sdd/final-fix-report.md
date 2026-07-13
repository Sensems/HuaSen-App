# Final notes-list review fixes

**Date:** 2026-07-13  
**Branch:** `master`  
**Commit message:** `fix: harden notes list fetch races and shell polish`

## Summary

Addressed the four Important findings from the final notes-list code review in one pass:

1. **Stale search/replace UX** — Replace fetches (`loadInitial` / `search` / `clearSearch` / `setFilter`) clear `items` up front and reset loading flags, so old keyword results are not shown during reload. On failure, state keeps an empty list and sets `errorMessage` for the existing empty-state retry UI. Pull-to-refresh still keeps items and toasts via `$message.error`.
2. **Concurrent fetch races** — Added monotonic `_fetchGeneration`; responses from superseded requests are ignored so rapid search/filter cannot overwrite newer state.
3. **White cards on cream canvas** — `NoteListCard` and expandable search fill use `AppColors.lightSurface` / `AppColors.darkSurface` by brightness (elevated white on light canvas `#f8f7f4`).
4. **Shell peers** — `DraftsScreen` and `SettingsScreen` app bars use `showBack: false`.

## Files touched

- `lib/features/notes/notes_list_notifier.dart`
- `lib/features/notes/notes_list_screen.dart` (refresh toast path unchanged; replace clears via notifier)
- `lib/features/notes/widgets/note_list_card.dart`
- `lib/features/notes/widgets/expandable_search_button.dart`
- `lib/features/wechat/drafts_screen.dart`
- `lib/features/settings/settings_screen.dart`

## Verify (`flutter analyze`)

```text
Analyzing 6 items...
No issues found! (ran in 1.2s)
```

Command:

```bash
flutter analyze lib/features/notes/notes_list_notifier.dart \
  lib/features/notes/notes_list_screen.dart \
  lib/features/notes/widgets/note_list_card.dart \
  lib/features/notes/widgets/expandable_search_button.dart \
  lib/features/wechat/drafts_screen.dart \
  lib/features/settings/settings_screen.dart
```

Exit code: `0`
