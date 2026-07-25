# Task 3 Report: Background service entry (Android probe isolate)

**Status:** DONE  
**Branch:** master (working-tree only, no commit)  
**Date:** 2026-07-24

## Summary

Created `drafts_background_service.dart` (no Riverpod) with configure / start / stop APIs and a `@pragma('vm:entry-point')` probe loop that reuses `DraftsWatchSnapshotStore` + Dio/token stack. Wired `initializeDraftsBackgroundService()` from `main.dart` on Android only via Web-safe `kIsWeb` + `defaultTargetPlatform`. Did **not** wire AppLifecycleListener pause/resume (Task 4).

> Note: `.superpowers/sdd/task-3-brief.md` on disk still contains an unrelated CategoryTagPicker brief. Implementation followed the user task prompt + `docs/superpowers/plans/2026-07-23-android-drafts-background-notify.md` Task 3.

## Changes

### 1. Created `lib/features/wechat/drafts_background_service.dart`

| Symbol | Role |
|--------|------|
| `initializeDraftsBackgroundService()` | Create sync channel + `FlutterBackgroundService.configure` (`dataSync`, `autoStart: false`) |
| `startDraftsBackgroundService()` | Start if not running |
| `stopDraftsBackgroundService()` | `invoke('stop')` if running |
| `draftsBackgroundServiceOnStart` | Isolate entry: FG notification, Timer probe, silent errors |
| Events | UI→service `'stop'`; service→UI `'draftsUpdated'` |

Probe behavior (matches coordinator):
- Requires access + refresh tokens; otherwise `stopSelf()`
- `listNotes(type: 'DRAFT', page: 1, size: notesPageSize)`
- Load/save snapshot via `DraftsWatchSnapshotStore`
- On new drafts: `LocalNotificationService.showDraftsUpdate` + `invoke('draftsUpdated')`
- Interval: `AppConstants.draftsWatchIntervalSeconds`

### 2. Modified `lib/main.dart`

- After notification init, `await _initAndroidBackgroundService()`
- `_initAndroidBackgroundService`: skip if `kIsWeb`; configure only when `defaultTargetPlatform == TargetPlatform.android` (no bare `dart:io` Platform)

## Package API adaptations (flutter_background_service 5.1.0)

Installed API matched the plan sample for `AndroidConfiguration`, `AndroidForegroundType.dataSync`, `AndroidServiceInstance.setAsForegroundService` / `setForegroundNotificationInfo`, `startService` / `isRunning` / `invoke` / `stopSelf`.

Intentional adaptations (behavior preserved / tightened):

1. **Create notification channel before `configure()`** — package docs require the channel to exist before configure; also re-create in `onStart` (idempotent).
2. **`autoStartOnBoot: false`** — package default is `true`; set false so boot does not resurrect the FG service (process-alive / A-tier only).
3. **Hoist Dio / `TokenRefresher` once per service lifetime** and `refresher.cancel()` in `stopSelf` — avoids leftover proactive-refresh timers; same probe semantics as constructing per tick.

## Verification

```text
flutter analyze lib/features/wechat/drafts_background_service.dart lib/main.dart
No issues found! (ran in 48.9s)
```

(Re-run after TokenRefresher hoist: No issues found.)

## Self-review

- No Riverpod imports in the service isolate module.
- Web/Chrome still compiles: `defaultTargetPlatform` behind `kIsWeb` guard.
- Task 4 scope left alone: coordinator pause/resume and `app.dart` `draftsUpdated` listener not wired; `start`/`stop` helpers are ready for Task 4.
- Unrelated working-tree files untouched.
- No commits.

## Concerns

- None blocking. Manual Android QA (ongoing notification + background probe) remains Task 5.
- Stale `task-3-brief.md` content (CategoryTagPicker) may confuse later agents; consider regenerating the brief for this plan.
