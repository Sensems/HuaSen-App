# Final Review Re-review — Important Fixes Only

**Reviewer:** Senior Code Reviewer (re-gate)  
**Date:** 2026-07-24  
**Prior gate:** `.superpowers/sdd/final-review.md` (Needs fixes — 2 Important)  
**Fix report:** `.superpowers/sdd/task-5-report.md` (Final-review Important fixes)  
**Package:** `.superpowers/sdd/final-fix-review-pkg.md`  
**Verified on disk:** `drafts_watch_snapshot_store.dart`, `drafts_background_service.dart`, `drafts_watch_coordinator.dart`, `token_refresher.dart`

---

## Important #1 — SharedPreferences.reload() before cross-isolate snapshot load

**Fixed: yes**

Evidence:

- `DraftsWatchSnapshotStore.load` calls `await prefs.reload()` before reading any snapshot keys (`drafts_watch_snapshot_store.dart` L13–15).
- `DraftsWatchCoordinator._loadSnapshot` calls `await prefs.reload()` before `_snapshotStore.load` on resume/start (`drafts_watch_coordinator.dart` L121–126); resume path flows through `_startAsync` → `_loadSnapshot` → immediate `probe()`.
- Background isolate reloads prefs in `hasAuthTokens()` (L145–146) and again via `_store.load` (which reloads internally) before each probe.

This matches the spec/plan contract: main isolate sees FG-service snapshot writes on resume, preventing duplicate「新草稿」notifications from stale baseline.

---

## Important #2 — Refresh/auth failure stops FG service immediately

**Fixed: yes**

Evidence:

- `TokenRefresher.onSessionExpired` wired to `unawaited(stopSelf())` at service startup (`drafts_background_service.dart` L135–138).
- `scheduleProactiveRefresh()` wired in the same block (L139).
- `TokenRefresher.expireSession()` clears tokens then invokes `onSessionExpired` once (`token_refresher.dart` L72–79); called on refresh failure, proactive refresh failure, and 401 paths via `AuthInterceptor` (`auth_interceptor.dart` L43–49).
- `probeOnce` stops immediately when tokens missing at entry (L159–161), after failed `listNotes` when tokens cleared without throw (L171–176), and in `on Object` when tokens gone post-error (L192–196).

401 → refresh failure → `expireSession()` → `onSessionExpired` → `stopSelf()` in the same probe/tick, not after the next 30s interval.

---

## Optional Minor — non-Android onPause keeps main timer

**Fixed: yes**

Evidence:

- `AppLifecycleListener.onPause` only calls `pauseMainPollingForBackground()` when `defaultTargetPlatform == TargetPlatform.android` and authenticated (`drafts_watch_coordinator.dart` L46–53).
- Non-Android/Web skip pause handoff; main-isolate `Timer.periodic` continues.

---

## New Critical / Important introduced?

**None identified.**

Fixes are additive and aligned with prior recommendations. Double `reload()` in coordinator `_loadSnapshot` + store `load` is redundant but harmless. Remaining original Minor items (unawaited persist before FG start on pause; resume stop/start race) were not in scope and remain open — not escalated.

Manual Android QA (Task 5 scenarios 1–5) remains **PENDING_USER**; not re-litigated as Critical per prior gate.

---

## Verdict

**Ready with nits**

Important blockers from the prior gate are resolved in code. Ship/merge from static review is acceptable; complete device QA and optional Minor #2/#3 from the original review before production confidence.
