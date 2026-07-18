# Drafts Watch + Local Notify — Design Spec

**Date:** 2026-07-16  
**Status:** Approved (brainstorm)  
**App:** Flutter app at repository root

## Goal

1. While the user is logged in and the app process is alive, **continuously poll** draft notes (~every 30s).
2. When **new drafts** are detected, refresh the drafts list and tab badge.
3. When the user is **not** currently viewing the drafts screen, show a **system local notification**.
4. Cover **all target platforms** for polling; system notifications on mobile/desktop; **Web degrades** to silent refresh only.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Approach | **1** — in-process `Timer.periodic` + `flutter_local_notifications` (no FCM / no kill-process wake) |
| Lifecycle | Foreground + background while process alive; **not** after process kill |
| Update signal | **New drafts only** (new ids / total increase); ignore content-only edits and deletes-from-elsewhere as notify triggers |
| Interval | ~30 seconds (`AppConstants`, tunable constant) |
| On drafts screen | Silent refresh of list + badge; **no** system notification |
| Platforms | Android / iOS / Windows / macOS: poll + local notify; Web (and Linux if run): poll + silent UI only |
| Auth binding | Start on `AuthStatus.authenticated`; stop on logout / session expired |
| Data layer | Reuse `NotesService.listNotes`; no Drift / Repository |
| Verification | Manual QA only (no new automated tests this phase) |

## Out of scope

- Server push (FCM / APNs / WebSocket draft events)
- `Workmanager` / foreground-service persistence after process death
- Settings UI toggle for draft notifications
- Browser Notification API on Web
- Drift / Repository refactor
- Automated tests

## Backend reference

| Method | Path | Query | Response |
|--------|------|-------|----------|
| GET | `/notes` | `type=DRAFT` (same string as `DraftsListNotifier` / badge), `page=1`, `size=notesPageSize` | `ApiResponse<PaginatedNotes>` (`items`, `total`, `page`, `size`) |

Probe uses the same wire format as the drafts list. No new endpoints.

## Architecture

```
AuthNotifier (authenticated / logout / session expired)
        │ start / stop
        ▼
DraftsWatchCoordinator (Riverpod, keepAlive)
  ├─ Timer.periodic(~30s) + AppLifecycle listener
  ├─ NotesService.listNotes(type: DRAFT, page: 1, size: pageSize)
  ├─ Snapshot: knownIds + knownTotal
  ├─ On new drafts → draftsListProvider.refresh() + draftsCountProvider.refresh()
  └─ If not on drafts route → LocalNotificationService.show(...)
              └─ flutter_local_notifications
                 Web: no-op for show()

Tap notification → navigate to AppConstants.routeDrafts (/drafts)
```

Dependency direction unchanged: `features` / thin `core` helper → `data` / `core`. Coordinator must not import page widgets; it may read router location via a small callback / provider.

| Unit | Responsibility |
|------|----------------|
| `DraftsWatchCoordinator` | Start/stop timer, probe, compare, trigger refresh + notify |
| Snapshot (`knownIds`, `knownTotal`) | In-memory only; cleared on logout |
| `LocalNotificationService` | Init, permission request, show, tap → `/drafts` |
| Existing `DraftsListNotifier` / `draftsCountProvider` | UI state; coordinator calls `refresh()` |

### Suggested file placement

| Piece | Path (suggested) |
|-------|------------------|
| Coordinator + provider | `lib/features/wechat/drafts_watch_coordinator.dart` |
| Notification service | `lib/core/notifications/local_notification_service.dart` |
| Interval / channel constants | `lib/core/constants/app_constants.dart` (+ `UiStrings` for copy) |
| Wire-up | `main.dart` (plugin init) + `AuthNotifier` or app-level listener to start/stop |
| Platform config | Android manifest / iOS `Info.plist` / desktop as required by plugin |

Exact class names may adjust during implementation as long as responsibilities stay the same.

## Data flow

### Start / stop

1. Enter `AuthStatus.authenticated` (including cold-start bootstrap) → start coordinator: **immediate probe**, then every ~30s.
2. `forceLogout` / session expired → cancel timer, clear snapshot.
3. `AppLifecycleState.detached` → cancel timer.
4. Return to `resumed` / `inactive` / `paused` while still authenticated → restart if stopped; run an immediate probe.

`paused` does **not** stop the timer (background while process alive). OS may throttle timers; that is acceptable.

### Probe algorithm

1. Call `listNotes(type: DRAFT, page: 1, size: notesPageSize)` (no `mediaType` filter — same universe as badge total).
2. On failure: silent skip; keep previous snapshot; wait for next tick. No toast.
3. On success:
   - **No baseline yet:** set `knownIds` = ids from this page, `knownTotal` = `total`; **do not notify**.
   - **Has baseline:**
     - `newIds = pageIds − knownIds`
     - If `newIds` non-empty → treat as new drafts (primary signal).
     - Else if `total > knownTotal` → treat as new drafts that may sit beyond page 1 (secondary signal).
     - Else → **no notify and no forced UI refresh** (pull-to-refresh / tab entry remain user-driven).
4. When new drafts detected:
   - Update snapshot: merge new ids into `knownIds`; set `knownTotal = total`.
   - Always call `draftsCountProvider.notifier.refresh()`.
   - Call `draftsListProvider.notifier.refresh()` (safe no-op / early-return if list is mid-load is fine).
   - If current location is **not** drafts (`AppConstants.routeDrafts`) → show local notification.
   - If on drafts → silent only (refresh already applied).

### Local delete sync

When the user deletes a draft in-app (`deleteDraft` success), remove that id from `knownIds` and decrement `knownTotal` (floor at 0) so a later re-fetch does not false-positive.

### Notification copy

| Case | Title / body (Chinese) |
|------|------------------------|
| Single new id with title | Title: `新草稿`; body: note title or `无标题` |
| Single without usable title | body: `无标题` |
| Multiple / total-only bump | `有 N 条新草稿` (N = `newIds.length` if known, else `total - previousTotal`) |

### Tap behavior

Notification tap opens/resumes the app and navigates to `/drafts`.

## Platform notes

| Platform | Polling | System notification |
|----------|---------|---------------------|
| Android | Timer while process alive | `flutter_local_notifications` + notification channel (e.g. 「草稿更新」) |
| iOS | Same (may be throttled in background) | Same + permission request |
| Windows / macOS | Same | Same (plugin desktop support) |
| Web | Same silent refresh path | **No** system notification this iteration |
| Process killed | Not guaranteed | Out of scope |

Permissions: if the user denies notification permission, continue polling and UI refresh; `show` becomes a no-op.

## Error handling

| Case | Behavior |
|------|----------|
| Probe API error / network | Silent; keep snapshot |
| Notification show failure | Silent; data refresh already applied |
| 401 / session expired | Existing auth path stops coordinator; no probe-specific toast |

## Testing (manual)

1. Login → within ~30s probes run; create a draft from another client/session → off drafts tab: system notification + badge/list update.
2. Stay on drafts tab when a new draft appears → list/badge update, **no** system notification.
3. Logout → polling stops; no further notifications.
4. Background app without killing process → still notified within a reasonable delay (OS throttle OK).
5. Chrome/Web → list/badge can update; no crash; no requirement for system notification.

## Relationship to prior specs

Builds on [2026-07-14-drafts-list-design.md](./2026-07-14-drafts-list-design.md) (list + badge). Does not change filter chips, card UI, or delete API contracts.
