# Task 3 Review: Background service entry (Android probe isolate)

**Reviewer:** Code review gate (task-scoped)  
**Date:** 2026-07-24  
**Brief:** `.superpowers/sdd/task-3-brief.md`  
**Report:** `.superpowers/sdd/task-3-report.md`  
**Diff:** `.superpowers/sdd/task-3-review-pkg.md`

---

## Verdict

| Gate | Result |
|------|--------|
| **Spec compliance** | ✅ |
| **Task quality** | Approved |

Task 3 deliverables are complete within scope: the Android drafts foreground-service module (configure / start / stop / entry-point probe loop) and Web-safe `main.dart` initialization. No out-of-scope files; no Riverpod in the service isolate; Task 4 lifecycle wiring correctly deferred.

---

## Spec Compliance Checklist

### Required — present and correct

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Create `drafts_background_service.dart` | ✅ | New file in review package |
| `initializeDraftsBackgroundService()` | ✅ | Creates sync channel, `FlutterBackgroundService.configure` |
| `startDraftsBackgroundService()` / `stopDraftsBackgroundService()` | ✅ | Start if not running; `invoke('stop')` when running |
| `@pragma('vm:entry-point') draftsBackgroundServiceOnStart` | ✅ | L91–184 |
| Android FG service `dataSync`, `autoStart: false`, `isForegroundMode: true` | ✅ | `AndroidConfiguration` L41–51 |
| Ongoing notification channel/id/title/body from constants | ✅ | `AppConstants` + `UiStrings` |
| Probe: `listNotes(type: 'DRAFT', page: 1, size: notesPageSize)` | ✅ | L152–156 |
| Interval: `AppConstants.draftsWatchIntervalSeconds` | ✅ | L180–182 |
| Snapshot via `DraftsWatchSnapshotStore` load/save | ✅ | `_store.load` / `_store.save` |
| Business notify via `LocalNotificationService.showDraftsUpdate` | ✅ | L169–170 |
| Events: UI→service `'stop'`, service→UI `'draftsUpdated'` | ✅ | L133–135, L171 |
| Missing tokens → `stopSelf()` | ✅ | L143–149 |
| Silent errors on probe failure | ✅ | L172–174 |
| No Riverpod in service module | ✅ | No riverpod imports |
| `main.dart`: Android-only configure, Web-safe | ✅ | `_initAndroidBackgroundService` with `kIsWeb` + `defaultTargetPlatform` |
| Call initialize before `runApp` | ✅ | L243 in diff (after notification init, before `runApp`) |
| No FG lifecycle pause/resume (Task 4) | ✅ | Not in diff |
| `flutter analyze` on scoped files | ✅ | Re-run: `No issues found!` |

### Intentional improvements (within spec)

| Adaptation | Status | Notes |
|------------|--------|-------|
| Create notification channel before `configure()` | ✅ | Required by `flutter_background_service` 5.x; idempotent re-create in `onStart` |
| `autoStartOnBoot: false` | ✅ | Tightens brief’s `autoStart: false` — prevents boot resurrection |
| Hoist Dio/`TokenRefresher` once; `refresher.cancel()` in `stopSelf` | ✅ | Brief allows; avoids orphaned proactive-refresh timers |

---

## Report Accuracy

| Report claim | Verified |
|--------------|----------|
| Service APIs + events match brief | ✅ |
| Probe semantics match coordinator | ✅ |
| No Riverpod in service isolate | ✅ |
| Web-safe Android-only init in `main.dart` | ✅ |
| Task 4 lifecycle not wired | ✅ |
| Package API adaptations documented | ✅ |
| `flutter analyze` succeeded | ✅ Re-confirmed |
| No commits | ✅ (review package only) |
| "Concerns: None blocking" | ✅ Accurate for Task 3 scope |

---

## Task Quality Assessment

### What is well-built

- **Brief fidelity:** Probe loop, snapshot diff, notification body helper, and event names align with the brief sample and mirror `DraftsWatchCoordinator` probe logic (without Riverpod).
- **Isolate bootstrap:** `DartPluginRegistrant.ensureInitialized()`, `WidgetsFlutterBinding.ensureInitialized()`, FG promotion via `AndroidServiceInstance`, and channel setup are in the right order.
- **Stop path:** `stop` listener cancels timer, cancels `TokenRefresher`, and calls `stopSelf()` — clean teardown.
- **Concurrency guard:** `probing` flag prevents overlapping probes on slow network.
- **Main entry:** `_initAndroidBackgroundService` avoids `dart:io` `Platform`, satisfying Web compile requirements.
- **Scope discipline:** Only the two task files changed; no coordinator / `app.dart` lifecycle wiring.

### Minor notes (non-blocking)

- **Auth failure stop latency:** When refresh fails mid-probe (401 → `expireSession`), the service stops on the *next* probe’s token check, not synchronously in the catch block. Matches the brief’s silent-error sample; broader design doc mentions immediate stop — acceptable deferral; Task 4/5 can tighten if needed.
- **SharedPreferences cross-isolate cache:** Service holds one `SharedPreferences` instance per isolate; token/snapshot writes from the main isolate are not visible in-memory until re-read. Expected for multi-isolate architecture; Task 4 handoff should coordinate pause/resume snapshot sync.
- **`stopDraftsBackgroundService` is fire-and-forget:** `invoke('stop')` is not awaited (brief sample identical); acceptable for Task 3 helpers consumed in Task 4.

---

## Findings Summary

| Severity | Finding |
|----------|---------|
| **Critical** | None |
| **Important** | None |
| **Minor** | Refresh failure stops service on next probe tick, not immediately (brief-consistent) |
| **Minor** | Cross-isolate SharedPreferences staleness is architectural; Task 4 owns handoff |
| **Minor** | `stopDraftsBackgroundService` does not await service teardown (brief-consistent) |

---

## Recommended Actions

None required for Task 3 gate. Proceed to Task 4 (coordinator lifecycle start/stop + `draftsUpdated` listener).
