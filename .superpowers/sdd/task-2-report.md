# Task 2 Report: Snapshot SharedPreferences store

**Status:** DONE  
**Branch:** master (working-tree only, no commit)  
**Date:** 2026-07-24

## Summary

Added `DraftsWatchSnapshotStore` to persist drafts-watch baseline (known ids, total, hasBaseline) in SharedPreferences, and wired `DraftsWatchCoordinator` to load on start, save after probe/delete, and clear on stop. Enables sharing snapshot state between UI and future background isolates (Task 4).

## Changes

### 1. Created `lib/features/wechat/drafts_watch_snapshot_store.dart`

- `DraftsWatchSnapshotStore` with `load`, `save`, `clear`
- Known ids stored as comma-separated UUID string
- Uses `AppConstants.keyDraftsWatchKnownIds`, `keyDraftsWatchKnownTotal`, `keyDraftsWatchHasBaseline`
- `save` calls `clear` when snapshot has no baseline

### 2. Modified `lib/features/wechat/drafts_watch_coordinator.dart`

| Hook | Behavior |
|------|----------|
| `start()` | Delegates to `_startAsync`; `await _loadSnapshot()` before timer/probe |
| `stop()` | Resets in-memory snapshot; `unawaited(_clearSnapshotPrefs())` |
| `probe()` | After `_snapshot = diff.next`, `await _persistSnapshot()` before early return/notify |
| `onLocalDraftDeleted()` | Updates snapshot; `unawaited(_persistSnapshot())` |

Private helpers: `_prefs()`, `_persistSnapshot()`, `_loadSnapshot()`, `_clearSnapshotPrefs()`.

### 3. `drafts_list_notifier.dart`

Not modified — delete path already calls `draftsWatchProvider.notifier.onLocalDraftDeleted(id)`.

## Verification

```text
flutter analyze lib/features/wechat/drafts_watch_snapshot_store.dart lib/features/wechat/drafts_watch_coordinator.dart
No issues found!
```

## Self-review

- Store implementation matches brief exactly (comma-separated ids, clear-on-no-baseline save).
- Coordinator load-before-probe prevents duplicate notifications after process restart when prefs hold a baseline.
- `stop()` clears prefs so logout/detach does not leave stale baseline for next session.
- Task 4 FG service pause/resume intentionally not implemented.
- No automated tests per task scope.

## Concerns

None.
