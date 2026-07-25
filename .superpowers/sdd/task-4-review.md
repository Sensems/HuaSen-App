# Task 4 Review: Coordinator lifecycle handoff + UI refresh bridge

**Reviewer:** Code review gate (task-scoped)  
**Date:** 2026-07-24  
**Brief:** `.superpowers/sdd/task-4-brief.md`  
**Report:** `.superpowers/sdd/task-4-report.md`  
**Diff:** `.superpowers/sdd/task-4-review-pkg.md`

---

## Verdict

| Gate | Result |
|------|--------|
| **Spec compliance** | ✅ |
| **Task quality** | Approved |

Task 4 deliverables are complete within scope: Android pause/resume handoff between main coordinator timer and FG service, full `stop()` teardown, and `app.dart` bridge from service `draftsUpdated` to drafts list/count refresh. Drafts-route mute was not restored. Only the two scoped files changed.

---

## Spec Compliance Checklist

### Step 1 — Coordinator pause vs full stop

| Requirement | Status | Evidence |
|-------------|--------|----------|
| `pauseMainPollingForBackground()` cancels main timer, keeps snapshot | ✅ | L63–71 |
| Pause persists snapshot (does not clear) | ✅ | `unawaited(_persistSnapshot())` L67 |
| Android pause starts FG service | ✅ | `startDraftsBackgroundService()` guarded L68–70 |
| Non-Android does not start FG service | ✅ | Platform guard on service start |
| `resumeMainPollingFromBackground()` stops FG service (Android) | ✅ | L75–77 |
| Resume restarts main polling with immediate probe when authenticated | ✅ | `start(immediateProbe: true)` L78–80 |
| `AppLifecycleListener.onPause` → pause when authenticated | ✅ | L46–49 |
| `AppLifecycleListener.onResume` → resume when authenticated | ✅ | L51–55 |
| `AppLifecycleListener.onDetach` → `stop()` | ✅ | L45 |
| Full `stop()` stops FG service | ✅ | `unawaited(stopDraftsBackgroundService())` L102 |
| Full `stop()` clears in-memory snapshot + prefs | ✅ | L103–104 |
| Do not clear snapshot inside pause | ✅ | No clear in `pauseMainPollingForBackground` |
| Do not restore drafts-route mute | ✅ | `_isOnDraftsRoute` removed; notify always when new drafts |

### Step 2 — `app.dart` UI refresh bridge

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Android-only `draftsUpdated` subscription | ✅ | `_listenBackgroundDraftUpdates` L102–109 |
| Post-frame setup in `initState` | ✅ | L94–99 |
| Refreshes `draftsCountProvider` + `draftsListProvider` | ✅ | L107–108 |
| Subscription cancelled in `dispose` | ✅ | L113–116 |
| Imports service package + drafts providers | ✅ | L5, L15–16 |

### Step 3 — Analyze

| Requirement | Status | Evidence |
|-------------|--------|----------|
| `flutter analyze` on scoped coordinator + app.dart | ✅ | Re-run: `No issues found!` |

### Supporting handoff behavior (in diff, brief-implied)

| Adaptation | Status | Notes |
|------------|--------|-------|
| `_startAsync` loads persisted snapshot before timer/probe | ✅ | Enables resume after service wrote snapshot in prefs |
| `probe()` / `onLocalDraftDeleted()` persist snapshot | ✅ | Keeps main + service snapshot aligned during handoff |
| `start()` delegates to async loader | ✅ | Required for cross-isolate snapshot continuity |

---

## Report Accuracy

| Report claim | Verified |
|--------------|----------|
| Pause keeps snapshot; only `stop()` clears prefs | ✅ |
| Android-only FG start/stop in pause/resume | ✅ |
| Full `stop()` stops service + clears snapshot | ✅ |
| Non-Android: no FG service; pause still cancels main timer | ✅ |
| `draftsUpdated` → list/count refresh in `app.dart` | ✅ |
| Drafts-route mute not restored | ✅ |
| Touched only coordinator + `app.dart` | ✅ (review package) |
| `flutter analyze` succeeded | ✅ Re-confirmed on scoped files |
| No commits | ✅ |

---

## Task Quality Assessment

### What is well-built

- **Brief fidelity:** Method names, lifecycle hooks, platform guards, and event bridge match the brief samples line-for-line where specified.
- **Handoff coherence:** Persist-on-pause + load-on-start closes the snapshot gap between main isolate and FG service (Task 3 dependency).
- **Teardown path:** Logout / dispose / detach all funnel through `stop()`, which now stops FG service and clears prefs — no orphaned service or stale snapshot after auth exit.
- **Scope discipline:** No coordinator lifecycle wiring duplicated in `app.dart`; bootstrap only listens for UI refresh events.
- **Subscription hygiene:** `_draftsUpdatedSub?.cancel()` before re-subscribe and in `dispose` avoids leaks on rebuild.

### Minor notes (non-blocking)

- **Non-Android pause stops main timer:** `pauseMainPollingForBackground()` cancels the timer on all platforms; only FG service start is Android-guarded. Brief sample code does the same; brief also notes optionally leaving the timer running on non-Android. Desktop/macOS polling therefore pauses until `onResume` (no FG replacement). Acceptable for Task 4; add a platform guard around timer cancel if continuous desktop polling while unfocused is desired later.
- **`stop()` calls `stopDraftsBackgroundService()` without platform guard:** Safe in practice (`isRunning()` no-op when service never started); matches brief’s unconditional `stop()` sample.
- **Fire-and-forget service start/stop:** `unawaited(...)` on pause/resume/stop mirrors brief and Task 3 helpers; manual Android QA for pause → notification → resume → UI refresh remains deferred.

---

## Findings Summary

| Severity | Finding |
|----------|---------|
| **Critical** | None |
| **Important** | None |
| **Minor** | Non-Android `onPause` cancels main timer (brief-allowed; optional “keep timer running” not implemented) |
| **Minor** | `stopDraftsBackgroundService()` invoked on all platforms in `stop()` (harmless no-op when not running) |

---

## Recommended Actions

None required for Task 4 gate. Proceed to manual Android QA (pause/resume handoff + background `draftsUpdated` UI refresh) in a later task.
