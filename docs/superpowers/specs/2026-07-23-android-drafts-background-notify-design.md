# Android Drafts Background Notify — Design Spec

**Date:** 2026-07-23  
**Status:** Implemented (manual Android QA pending)  
**App:** Flutter app at repository root  
**Extends:** [2026-07-16-drafts-watch-notify-design.md](./2026-07-16-drafts-watch-notify-design.md)

## Goal

On **Android only**, while the user is logged in and the **app process is still alive**, continue draft probing after the UI is backgrounded (app switch / lock screen) and show a **system local notification** when new drafts arrive.

Non-goals for this iteration:

- Guarantees after process kill / force-stop / reboot
- FCM / vendor push / draft WebSocket
- iOS / Web / desktop foreground-service behavior changes
- Settings UI toggle for draft sync notifications

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Scope | Android only; other platforms keep current in-process `Timer.periodic` |
| Coverage | Process-alive background (option A); not after process death |
| Transport | Existing REST `GET /notes?type=DRAFT` polling (~30s) |
| Keep-alive | Android **foreground service** via `flutter_background_service` (`dataSync`) |
| Persistent UI | Ongoing notification while service runs:「正在同步草稿」 |
| New-draft UI | Existing `flutter_local_notifications` channel `drafts_updates` |
| Snapshot | Persist `knownIds` / `knownTotal` / `hasBaseline` in SharedPreferences so UI isolate and service isolate share baseline |
| Auth in service | Read tokens from SharedPreferences; refresh on 401; refresh failure → stop service |
| Backend changes | None |

## Architecture

```
Auth authenticated
        │
        ▼
DraftsWatchCoordinator (main isolate)
  ├─ Foreground: Timer.periodic ~30s → probe (existing)
  └─ Android paused/hidden: stop main timer, start FG service
           │
           ▼
Drafts background onStart (separate isolate)
  ├─ Ongoing notification:「正在同步草稿」
  ├─ Timer ~30s → listNotes(type=DRAFT)
  ├─ Snapshot R/W SharedPreferences
  └─ New drafts → local 「新草稿」 notification
           │ optional invoke
           ▼
Main isolate (if alive): refresh draftsList + draftsCount

Android resumed → stop FG service, restore main Timer + immediate probe
Logout / session expired → stop timer + service, clear snapshot prefs
detached / process kill → best-effort end; no further probes required
```

Dependency direction unchanged: feature/coordinator → core helpers / data services patterns. Background isolate must **not** depend on Riverpod `Ref`; it constructs a minimal Dio + prefs stack.

## Lifecycle (Android)

| Event | Behavior |
|-------|----------|
| Login / cold start authenticated | Main isolate: immediate probe + 30s timer. **Do not** start FG service yet |
| `paused` / `hidden` while authenticated | Stop main timer; start FG service; service immediate probe then every 30s |
| `resumed` | Stop FG service; reload snapshot from prefs; restart main timer + immediate probe |
| Logout / session expired | Stop timer + service; clear in-memory and prefs snapshot |
| `detached` / process killed | Service ends with process; no wake after death |

Non-Android: keep current coordinator timer only; no FG service.

## Notifications

Two Android channels:

| Kind | Channel id | Name | Content | Behavior |
|------|------------|------|---------|----------|
| Ongoing (FG service) | `drafts_sync` | 草稿同步 | Title:「花森」(`UiStrings` constant); body:「正在同步草稿」 | `ongoing: true` while service running |
| Business (new draft) | existing `drafts_updates` | 草稿更新 | Title「新草稿」; body title /「无标题」/「有 N 条新草稿」 | Tap → `/drafts` (existing) |

## Probe algorithm

Same as existing `DraftsWatchSnapshot`:

1. `listNotes(type: DRAFT, page: 1, size: notesPageSize)`
2. Failure: silent skip; keep previous snapshot
3. No baseline: set baseline; do not notify
4. Baseline: new ids or `total` increase → update snapshot, show business notification, refresh list/badge when main isolate available
5. Local in-app delete: update snapshot (and prefs) so re-fetch does not false-positive

Interval: `AppConstants.draftsWatchIntervalSeconds` (30).

## Auth in background isolate

1. Read `access_token` / `refresh_token` / `expires_at` from SharedPreferences keys already used by the app
2. Attach Bearer on notes requests
3. On 401: call existing refresh endpoint; persist new tokens; retry once
4. If refresh fails or tokens missing: stop FG service (treat as logged out for watch purposes). Main auth path remains source of truth when UI resumes

## File / platform changes (expected)

| Area | Change |
|------|--------|
| `pubspec.yaml` | Add `flutter_background_service` (+ Android impl as required by package) |
| `AndroidManifest.xml` | `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_DATA_SYNC`, and any plugin-required permissions; service entry with `foregroundServiceType="dataSync"` |
| `lib/main.dart` | Configure background service (`autoStart: false`) |
| `drafts_watch_coordinator.dart` | Android lifecycle start/stop service; snapshot prefs sync |
| New background entry file | `@pragma('vm:entry-point')` onStart: timer, probe, notify, optional invoke |
| Snapshot prefs helper | Serialize/deserialize baseline |
| `AppConstants` / `UiStrings` | Ongoing channel id + copy |

## Out of scope

- Server push (FCM, vendor push, WebSocket draft events)
- Workmanager-only sparse polling as the primary path
- Battery-optimization whitelist UX (may document as optional manual tip later)
- Automated tests (manual QA only, consistent with prior drafts-watch phase)

## Manual QA (Android)

1. Login → foreground probing continues ~30s; no ongoing sync notification while app is resumed
2. Background app (do not kill) → ongoing「正在同步草稿」appears; create draft elsewhere → within ~30s「新草稿」notification
3. Return to foreground → ongoing notification dismissed; list/badge updated or refresh shortly after
4. Logout → service stopped; ongoing gone; no further probes
5. Kill process → no requirement to keep notifying

## Relationship to prior spec

Supersedes the Android background expectation in [2026-07-16-drafts-watch-notify-design.md](./2026-07-16-drafts-watch-notify-design.md) where “OS may throttle timers” was accepted without a keep-alive. Foreground behavior, Web no-op notifications, and probe diff rules remain as before unless noted above.
