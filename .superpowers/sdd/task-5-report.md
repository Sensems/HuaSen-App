# Task 5 Report: Full analyze + manual Android QA checklist

**Status:** DONE (analyze clean; manual QA **PENDING_USER**)  
**Branch:** master (working-tree only, no commit)  
**Date:** 2026-07-24  
**Plan:** `docs/superpowers/plans/2026-07-23-android-drafts-background-notify.md`

---

## Summary

Ran full-project `flutter analyze` at repo root. **No issues found** — no feature-related fixes required. Manual Android device QA cannot be executed in this environment; checklist below is for the user to run with `flutter run -d <android-device>` (not Chrome).

---

## Step 1: Project analyze

**Command:**

```bash
flutter analyze
```

**Output:**

```text
Analyzing sebhua-notes-app...
No issues found! (ran in 27.2s)
```

**Exit code:** 0

**Fixes applied:** None (analyze clean on first run).

**Feature files reviewed (no analyzer findings):**

- `lib/features/wechat/drafts_background_service.dart`
- `lib/features/wechat/drafts_watch_snapshot_store.dart`
- `lib/features/wechat/drafts_watch_coordinator.dart`
- `lib/app.dart`
- `lib/main.dart`
- `lib/core/constants/app_constants.dart`
- `lib/core/constants/ui_strings.dart`
- `android/app/src/main/AndroidManifest.xml`
- `pubspec.yaml`

---

## Step 2: Manual Android QA checklist

**Runner:** User on physical device or Android emulator  
**Command:** `flutter run -d <android-device>`  
**Overall status:** **PENDING_USER**

| # | Scenario | Expected | Status |
|---|----------|----------|--------|
| 1 | Login → stay foreground ~30s+ | Draft probes continue; **no** ongoing「正在同步草稿」notification while app is resumed/foreground | **PENDING_USER** |
| 2 | Press Home / switch away (do not swipe-away kill) | Ongoing「正在同步草稿」notification appears (title「花森」) | **PENDING_USER** |
| 3 | Create a draft from another client/session | Within ~30s, system「新草稿」notification appears; tap opens `/drafts` | **PENDING_USER** |
| 4 | Return to app (resume) | Ongoing notification dismissed; drafts badge/list reflects new draft | **PENDING_USER** |
| 5 | Logout | Ongoing notification gone; no further draft probes or notifications | **PENDING_USER** |
| 6 | Kill process from recents | No requirement to keep notifying after process death (A-tier acceptable) | **PENDING_USER** |

### QA prerequisites

- Logged-in account with valid access/refresh tokens in SharedPreferences.
- POST_NOTIFICATIONS granted on Android 13+.
- Second client/session (or API) to create a draft while app is backgrounded.
- Network reachable at configured `API_BASE_URL`.

### Known non-blockers (from Tasks 1–4 reviews)

- Non-Android `onPause` cancels main timer without FG service; resume restores polling (spec allows).
- Token refresh failure in service isolate stops the service on next probe (by design).
- SharedPreferences cross-isolate cache staleness is a theoretical edge case; baseline is persisted on pause.

---

## Step 3: Plan / progress notes

- Tasks 1–4: implemented in working tree (prior reports).
- Task 5 analyze: **complete**.
- Task 5 manual QA: **PENDING_USER** — blocks declaring feature fully verified on device.
- No git commit (per instructions).

---

## Concerns

None blocking analyze or code merge readiness from a static-analysis perspective. Feature acceptance on Android still depends on user completing the manual QA table above.

---

## Final-review Important fixes (2026-07-24)

**Status:** DONE  
**Scope:** Important findings from Android drafts background notify final review (working-tree only, no commit).

### What fixed

1. **SharedPreferences cross-isolate cache**
   - `DraftsWatchSnapshotStore.load` now `await prefs.reload()` before reading snapshot keys.
   - Coordinator `_loadSnapshot` also reloads after `getInstance()` before load (resume sees FG-service writes).
   - Background `probeOnce` reloads via `hasAuthTokens()` before token/snapshot use.

2. **Refresh / auth failure stops FG service immediately**
   - `TokenRefresher.onSessionExpired` → `stopSelf()` (covers proactive refresh failure and 401 refresh → `expireSession`).
   - `scheduleProactiveRefresh()` wired in the service isolate.
   - After a failed notes probe (`!isSuccess` or thrown error), re-check tokens; if access/refresh missing/empty, `stopSelf()` in the same probe (not next 30s tick).
   - Non-auth probe errors remain silent.

3. **Optional Minor — non-Android `onPause`**
   - `onPause` only calls `pauseMainPollingForBackground()` on Android.
   - Non-Android keeps the main-isolate Timer running through pause.

### Analyze

**Command:**

```bash
flutter analyze lib/features/wechat/drafts_watch_snapshot_store.dart lib/features/wechat/drafts_background_service.dart lib/features/wechat/drafts_watch_coordinator.dart
```

**Output:**

```text
Analyzing 3 items...
No issues found! (ran in 0.9s)
```

**Exit code:** 0
