# Task 4 Report: Coordinator lifecycle handoff + UI refresh bridge

**Status:** DONE  
**Branch:** master (working-tree only, no commit)  
**Date:** 2026-07-24

## Summary

Split Android background handoff from full `stop()` in `DraftsWatchCoordinator`: `onPause` pauses the main timer (keeps snapshot) and starts the FG service on Android only; `onResume` stops the FG service and restarts main polling with an immediate probe. Full `stop()` (logout / dispose / detach) also stops the FG service and clears snapshot prefs. `_DraftsWatchBootstrap` listens for service event `draftsUpdated` on Android and refreshes drafts list/count. Did **not** restore `_isOnDraftsRoute` mute.

## Changes

### 1. Modified `lib/features/wechat/drafts_watch_coordinator.dart`

| Symbol / hook | Behavior |
|---------------|----------|
| `pauseMainPollingForBackground()` | Cancel main `Timer`; persist `_snapshot` (do not clear); Android → `startDraftsBackgroundService()` |
| `resumeMainPollingFromBackground()` | Android → `stopDraftsBackgroundService()`; if authenticated → `start(immediateProbe: true)` |
| `stop()` | Cancel timer; `stopDraftsBackgroundService()`; clear in-memory + prefs snapshot |
| `AppLifecycleListener.onPause` | Authenticated → `pauseMainPollingForBackground()` |
| `AppLifecycleListener.onResume` | Authenticated → `resumeMainPollingFromBackground()` |
| `AppLifecycleListener.onDetach` | Unchanged → `stop()` |

Non-Android: service start/stop branches are guarded with `!kIsWeb && defaultTargetPlatform == TargetPlatform.android`. Pause still cancels the main timer (resume restarts it); no FG service is started.

### 2. Modified `lib/app.dart` (`_DraftsWatchBootstrap`)

- Post-frame `_listenBackgroundDraftUpdates()` on Android only
- Subscribes to `FlutterBackgroundService().on('draftsUpdated')`
- Refreshes `draftsCountProvider` + `draftsListProvider`
- Cancels subscription in `dispose`

## Verification

```text
flutter analyze lib/features/wechat/drafts_watch_coordinator.dart lib/features/wechat/drafts_background_service.dart lib/features/wechat/drafts_watch_snapshot_store.dart lib/app.dart lib/main.dart lib/core/constants/app_constants.dart lib/core/constants/ui_strings.dart
No issues found! (ran in 5.3s)
```

## Self-review

- Pause keeps snapshot; only full `stop()` clears prefs — matches brief.
- Always-notify behavior preserved (no drafts-route mute restored).
- Web/desktop: no FG service start; Chrome-safe via `kIsWeb` / `defaultTargetPlatform`.
- Touched only `drafts_watch_coordinator.dart` and `app.dart`.
- No commits.

## Concerns

- Non-Android `onPause` cancels the main timer with no FG replacement (brief-allowed); polling resumes on `onResume`. If desktop needs continuous process-alive polling while “paused”, would need a platform guard around timer cancel.
- Manual Android QA (pause → FG ongoing notification → resume → UI refresh) remains for later tasks.
