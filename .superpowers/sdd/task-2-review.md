# Task 2 Review: Snapshot SharedPreferences store

**Reviewer:** Code review gate (task-scoped)  
**Date:** 2026-07-24  
**Brief:** `.superpowers/sdd/task-2-brief.md`  
**Report:** `.superpowers/sdd/task-2-report.md`  
**Diff:** `.superpowers/sdd/task-2-review-pkg.md`

---

## Verdict

| Gate | Result |
|------|--------|
| **Spec compliance** | ❌ |
| **Task quality** | Changes required |

Task 2 persistence deliverables (`DraftsWatchSnapshotStore`, coordinator load/save/clear wiring) are **correct and complete**. The diff fails the task boundary because it bundles an unrelated notification-behavior change into `drafts_watch_coordinator.dart`.

---

## Spec Compliance Checklist

### Required — present and correct

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Create `DraftsWatchSnapshotStore` with `load` / `save` / `clear` | ✅ | New file matches brief verbatim |
| Known ids as comma-separated string | ✅ | `join(',')` on save; `split(',').where(...).toSet()` on load |
| Uses `AppConstants.keyDraftsWatchKnownIds`, `keyDraftsWatchKnownTotal`, `keyDraftsWatchHasBaseline` | ✅ | Store + keys from Task 1 |
| `save` calls `clear` when `!snapshot.hasBaseline` | ✅ | `drafts_watch_snapshot_store.dart` L32–35 |
| Coordinator: `_snapshotStore` field | ✅ | `drafts_watch_coordinator.dart` L23 |
| Load on start before timer/probe | ✅ | `_startAsync` awaits `_loadSnapshot()` first |
| `start()` → `unawaited(_startAsync(...))` pattern | ✅ | L52–65 |
| Persist after successful probe snapshot update | ✅ | `await _persistSnapshot()` after `_snapshot = diff.next` |
| Persist on `onLocalDraftDeleted` | ✅ | `unawaited(_persistSnapshot())` |
| `stop()`: reset memory + clear prefs | ✅ | L68–72 |
| Private helpers `_prefs`, `_persistSnapshot`, `_loadSnapshot`, `_clearSnapshotPrefs` | ✅ | L80–95 |
| `drafts_list_notifier.dart` unchanged (delete via coordinator) | ✅ | Not in diff; report accurate |
| No FG service pause/resume (Task 4) | ✅ | Not added |
| `flutter analyze` on scoped files | ✅ | Re-run: `No issues found!` |
| No automated tests | ✅ | N/A per brief |

### Required — violated

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Modify coordinator only for snapshot prefs wiring | ❌ | See out-of-scope findings below |

---

## Out-of-Scope Changes (Important)

These are **not** in the task 2 brief but appear in the coordinator diff:

### 1. Drafts-route notification mute removed

```diff
-      if (_isOnDraftsRoute()) return;
...
-  bool _isOnDraftsRoute() {
-    final loc = ref.read(routerProvider).state.matchedLocation;
-    return loc == AppConstants.routeDrafts;
-  }
```

Also drops `import '../../core/router/app_router.dart';`.

This changes user-visible notification behavior (notifications now fire even when the user is on `/drafts`). That may align with the broader product rule (no route mute per `AGENTS.md`), but it is **not** Task 2 scope and was not mentioned in the implementer report. Bundling it here blocks a clean task-scoped gate.

---

## Report Accuracy

| Report claim | Verified |
|--------------|----------|
| Store matches brief (comma-separated ids, clear-on-no-baseline) | ✅ |
| Coordinator load-before-probe | ✅ |
| Persist after probe / on delete; clear on stop | ✅ |
| `drafts_list_notifier.dart` not modified | ✅ |
| Task 4 FG handoff intentionally omitted | ✅ |
| `flutter analyze` succeeded | ✅ Re-confirmed |
| "Concerns: None" | ❌ Omits bundled `_isOnDraftsRoute` removal |

---

## Task Quality Assessment

### What is well-built

- **Store fidelity:** Implementation is a line-for-line match to the brief; empty-id edge cases handled (`raw.isEmpty`, `where isNotEmpty`).
- **Coordinator wiring:** Load completes before first probe, preventing duplicate baseline establishment after process restart when prefs hold state.
- **Probe ordering:** Persist runs after snapshot mutation and before the `!diff.hasNewDrafts` early return — correct for durability.
- **Stop semantics:** In-memory reset plus prefs `clear()` avoids leaving stale baseline for the next auth session.
- **Delete path:** Correctly reuses existing `onLocalDraftDeleted` hook; no notifier duplication.

### What needs change

1. **Scope isolation:** Revert the `_isOnDraftsRoute` / `app_router` hunk from this changeset (land in the task that owns notification policy, if not already done).
2. **Report:** Note any intentional cross-task edits; do not claim zero concerns when behavior changes are bundled.

### Minor notes

- **`stop()` / `start()` race:** `unawaited(_clearSnapshotPrefs())` on stop vs `await _loadSnapshot()` on start can briefly reload stale prefs if auth flips quickly. Brief explicitly specifies this pattern; acceptable for Task 2 but worth awareness for Task 4 handoff.
- **Redundant writes:** Probe persists even when `diff.next` equals prior snapshot (no new drafts). Harmless, slightly wasteful.
- **Set join order:** `knownIds.join(',')` order is non-deterministic; reload uses `toSet()` so semantics are preserved.

---

## Recommended Actions

1. Revert `_isOnDraftsRoute` removal and `app_router` import change from the Task 2 diff (or split into the owning task’s diff).
2. Update task report to reflect actual coordinator diff scope.
3. Re-submit for task-2 gate once the diff is task-pure.

No rework needed for the store implementation or the prefs wiring hooks — those are ready for Task 4 once scope is cleaned.

---

## Findings Summary

| Severity | Finding |
|----------|---------|
| **Important** | `_isOnDraftsRoute()` guard and helper removed — out of Task 2 scope; changes notification behavior |
| **Important** | Report claims "Concerns: None" but omits bundled coordinator behavior change |
| **Minor** | `stop()` unawaited clear vs `start()` awaited load can race on rapid auth/session flip (brief-specified) |
| **Minor** | Probe persists unchanged snapshots (redundant SharedPreferences writes) |
