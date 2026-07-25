# Android Drafts Background Notify Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On Android, while logged in and the process is alive, keep draft probing (~30s) after the UI is backgrounded via a foreground service, and show a system「新草稿」notification when new drafts arrive.

**Architecture:** Main-isolate `DraftsWatchCoordinator` keeps the existing Timer while resumed. On Android `paused`, it persists the snapshot to SharedPreferences, stops the main Timer (without clearing baseline), and starts `flutter_background_service` (`dataSync`). The service isolate runs the same probe/diff rules with a minimal Dio + token stack, shows the ongoing「正在同步草稿」notification, and shows business notifications via `flutter_local_notifications`. On `resumed`, stop the service and restore the main Timer.

**Tech Stack:** Flutter, Riverpod 3, Dio/`NotesService`, `flutter_local_notifications`, `flutter_background_service`, SharedPreferences, existing `DraftsWatchSnapshot`.

**Spec:** `docs/superpowers/specs/2026-07-23-android-drafts-background-notify-design.md`

**Working directory for all Flutter commands:** repository root (`d:\lbs\demo\sebhua-notes-app`).

## Global Constraints

- Work only on `master`; do not create branches or git worktrees.
- Android only for FG service; iOS/Web/desktop keep current in-process Timer (no service).
- Coverage is process-alive only; no FCM / vendor push / WebSocket / Workmanager-as-primary.
- No Drift / Repository.
- No automated tests this phase; verify with `flutter analyze` + manual Android QA.
- Poll interval: `AppConstants.draftsWatchIntervalSeconds` (`30`).
- Probe: `listNotes(type: 'DRAFT', page: 1, size: AppConstants.notesPageSize)`.
- Probe / notify failures: silent (no toast).
- Prefer Chinese copy in `UiStrings`; no hardcoded user-facing English for notifications.
- Commits only when the user explicitly asks (skip commit steps unless instructed).
- Background isolate must not use Riverpod `Ref`.

---

## File structure

| File | Responsibility |
|------|----------------|
| `pubspec.yaml` | Add `flutter_background_service` |
| `android/app/src/main/AndroidManifest.xml` | FG service permissions + service declaration |
| `lib/core/constants/app_constants.dart` | Ongoing channel id, snapshot prefs keys, FG notification id |
| `lib/core/constants/ui_strings.dart` | Ongoing channel / body / title「花森」 |
| `lib/features/wechat/drafts_watch_snapshot_store.dart` | Persist/load/clear `DraftsWatchSnapshot` via SharedPreferences |
| `lib/features/wechat/drafts_background_service.dart` | Configure + `@pragma('vm:entry-point')` onStart probe loop |
| `lib/features/wechat/drafts_watch_coordinator.dart` | Android pause/resume service handoff; always persist snapshot on changes |
| `lib/main.dart` | `initializeDraftsBackgroundService()` before `runApp` |
| `lib/app.dart` | Listen for service `draftsUpdated` → refresh list/count (optional but preferred) |

Reuse: `DraftsWatchSnapshot`, `LocalNotificationService` patterns, `SharedPreferencesTokenStorage`, `TokenRefresher`, `DioClient`, `NotesService`, `AppConstants` token keys.

---

### Task 1: Dependency, constants, Android manifest

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/core/constants/app_constants.dart`
- Modify: `lib/core/constants/ui_strings.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`

**Interfaces:**
- Produces:
  - `AppConstants.draftsSyncNotificationChannelId` → `'drafts_sync'`
  - `AppConstants.draftsSyncForegroundNotificationId` → `8801`
  - `AppConstants.keyDraftsWatchKnownIds` → `'drafts_watch_known_ids'`
  - `AppConstants.keyDraftsWatchKnownTotal` → `'drafts_watch_known_total'`
  - `AppConstants.keyDraftsWatchHasBaseline` → `'drafts_watch_has_baseline'`
  - UiStrings: `draftsSyncChannelName`, `draftsSyncChannelDescription`, `draftsSyncOngoingTitle` (`花森`), `draftsSyncOngoingBody` (`正在同步草稿`)

- [ ] **Step 1: Add dependency**

In `pubspec.yaml` `dependencies:` add (use current stable compatible with SDK ^3.12; resolve with pub get):

```yaml
  flutter_background_service: ^5.1.0
```

If pub resolves a newer compatible major, prefer the resolved version but keep API aligned with package README (`FlutterBackgroundService`, `AndroidConfiguration`, `AndroidForegroundType.dataSync`).

Run: `flutter pub get`  
Expected: exit 0.

- [ ] **Step 2: Extend AppConstants**

Append near existing drafts notification constants:

```dart
  /// Android channel for the foreground-service ongoing notification.
  static const String draftsSyncNotificationChannelId = 'drafts_sync';

  /// Notification id used by the drafts FG service ongoing notification.
  static const int draftsSyncForegroundNotificationId = 8801;

  /// SharedPreferences keys for drafts-watch baseline (main + service isolates).
  static const String keyDraftsWatchKnownIds = 'drafts_watch_known_ids';
  static const String keyDraftsWatchKnownTotal = 'drafts_watch_known_total';
  static const String keyDraftsWatchHasBaseline = 'drafts_watch_has_baseline';
```

- [ ] **Step 3: Extend UiStrings**

Near existing drafts notification strings:

```dart
  static const String draftsSyncChannelName = '草稿同步';
  static const String draftsSyncChannelDescription = '后台同步草稿时显示';
  static const String draftsSyncOngoingTitle = '花森';
  static const String draftsSyncOngoingBody = '正在同步草稿';
```

- [ ] **Step 4: Update AndroidManifest.xml**

Inside `<manifest>` (with existing permissions), add:

```xml
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
```

Inside `<application>` (before closing tag), add:

```xml
        <service
            android:name="id.flutter.flutter_background_service.BackgroundService"
            android:foregroundServiceType="dataSync"
            android:exported="false" />
```

Keep existing `POST_NOTIFICATIONS` and `INTERNET`.

- [ ] **Step 5: Verify analyze on constants only**

Run: `flutter analyze lib/core/constants/app_constants.dart lib/core/constants/ui_strings.dart`  
Expected: No issues found.

---

### Task 2: Snapshot SharedPreferences store

**Files:**
- Create: `lib/features/wechat/drafts_watch_snapshot_store.dart`
- Modify: `lib/features/wechat/drafts_watch_coordinator.dart` (persist on snapshot changes / load on start / clear on stop)
- Modify: `lib/features/wechat/drafts_list_notifier.dart` only if delete path must also persist (prefer store calls inside coordinator `onLocalDraftDeleted`)

**Interfaces:**
- Consumes: `DraftsWatchSnapshot`, `AppConstants` keys, `SharedPreferences`
- Produces:
  - `class DraftsWatchSnapshotStore`
  - `Future<DraftsWatchSnapshot> load(SharedPreferences prefs)`
  - `Future<void> save(SharedPreferences prefs, DraftsWatchSnapshot snapshot)`
  - `Future<void> clear(SharedPreferences prefs)`
  - Known ids stored as comma-separated string (ids are UUIDs without commas)

- [ ] **Step 1: Create store**

```dart
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'drafts_watch_snapshot.dart';

/// Persists [DraftsWatchSnapshot] for sharing between UI and background isolates.
class DraftsWatchSnapshotStore {
  const DraftsWatchSnapshotStore();

  Future<DraftsWatchSnapshot> load(SharedPreferences prefs) async {
    final hasBaseline =
        prefs.getBool(AppConstants.keyDraftsWatchHasBaseline) ?? false;
    if (!hasBaseline) {
      return const DraftsWatchSnapshot();
    }
    final raw = prefs.getString(AppConstants.keyDraftsWatchKnownIds) ?? '';
    final ids = raw.isEmpty
        ? <String>{}
        : raw.split(',').where((e) => e.isNotEmpty).toSet();
    final total = prefs.getInt(AppConstants.keyDraftsWatchKnownTotal) ?? 0;
    return DraftsWatchSnapshot(
      knownIds: ids,
      knownTotal: total,
      hasBaseline: true,
    );
  }

  Future<void> save(
    SharedPreferences prefs,
    DraftsWatchSnapshot snapshot,
  ) async {
    if (!snapshot.hasBaseline) {
      await clear(prefs);
      return;
    }
    await prefs.setBool(AppConstants.keyDraftsWatchHasBaseline, true);
    await prefs.setString(
      AppConstants.keyDraftsWatchKnownIds,
      snapshot.knownIds.join(','),
    );
    await prefs.setInt(
      AppConstants.keyDraftsWatchKnownTotal,
      snapshot.knownTotal,
    );
  }

  Future<void> clear(SharedPreferences prefs) async {
    await prefs.remove(AppConstants.keyDraftsWatchHasBaseline);
    await prefs.remove(AppConstants.keyDraftsWatchKnownIds);
    await prefs.remove(AppConstants.keyDraftsWatchKnownTotal);
  }
}
```

- [ ] **Step 2: Wire coordinator memory ↔ prefs**

In `DraftsWatchCoordinator`:

1. Add `final _snapshotStore = const DraftsWatchSnapshotStore();`
2. After every assignment to `_snapshot` that changes baseline (probe success, `onLocalDraftDeleted`, `stop` clear), call:
   `unawaited(_persistSnapshot());`
3. Implement:

```dart
  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> _persistSnapshot() async {
    final prefs = await _prefs();
    await _snapshotStore.save(prefs, _snapshot);
  }

  Future<void> _loadSnapshot() async {
    final prefs = await _prefs();
    _snapshot = await _snapshotStore.load(prefs);
  }

  Future<void> _clearSnapshotPrefs() async {
    final prefs = await _prefs();
    await _snapshotStore.clear(prefs);
  }
```

4. At the beginning of `start({bool immediateProbe = true})`, `await _loadSnapshot()` (make `start` async or kick `unawaited(_startAsync(...))` so load completes before first probe). Preferred pattern:

```dart
  void start({bool immediateProbe = true}) {
    unawaited(_startAsync(immediateProbe: immediateProbe));
  }

  Future<void> _startAsync({required bool immediateProbe}) async {
    await _loadSnapshot();
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.draftsWatchIntervalSeconds),
      (_) => unawaited(probe()),
    );
    if (immediateProbe) {
      await probe();
    }
  }
```

5. In `stop()`: cancel timer; `_snapshot = const DraftsWatchSnapshot();` then `unawaited(_clearSnapshotPrefs());`

6. In `probe()` after `_snapshot = diff.next;`, `await _persistSnapshot();` before early return / notify.

7. In `onLocalDraftDeleted`: update `_snapshot` then `unawaited(_persistSnapshot());`

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/features/wechat/drafts_watch_snapshot_store.dart lib/features/wechat/drafts_watch_coordinator.dart`  
Expected: No issues found.

---

### Task 3: Background service entry (Android probe isolate)

**Files:**
- Create: `lib/features/wechat/drafts_background_service.dart`
- Modify: `lib/main.dart` (call configure)

**Interfaces:**
- Consumes: `DraftsWatchSnapshotStore`, `DraftsWatchSnapshot`, `NotesService`, `DioClient`, `SharedPreferencesTokenStorage`, `TokenRefresher`, `LocalNotificationService` (or direct plugin show for business notify), `AppConstants`, `UiStrings`
- Produces:
  - `Future<void> initializeDraftsBackgroundService()`
  - `Future<void> startDraftsBackgroundService()`
  - `Future<void> stopDraftsBackgroundService()`
  - top-level `@pragma('vm:entry-point') Future<void> draftsBackgroundServiceOnStart(ServiceInstance service)`
  - Service → UI event name: `'draftsUpdated'`
  - UI → Service stop event: `'stop'`

- [ ] **Step 1: Implement service module**

Create `lib/features/wechat/drafts_background_service.dart` with roughly this structure (adjust imports / plugin API to the resolved package version; keep behavior identical):

```dart
import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/shared_preferences_token_storage.dart';
import '../../core/network/token_refresher.dart';
import '../../core/notifications/local_notification_service.dart';
import '../../data/services/notes_service.dart';
import 'drafts_watch_snapshot.dart';
import 'drafts_watch_snapshot_store.dart';

const _store = DraftsWatchSnapshotStore();

Future<void> initializeDraftsBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: draftsBackgroundServiceOnStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: AppConstants.draftsSyncNotificationChannelId,
      initialNotificationTitle: UiStrings.draftsSyncOngoingTitle,
      initialNotificationContent: UiStrings.draftsSyncOngoingBody,
      foregroundServiceNotificationId:
          AppConstants.draftsSyncForegroundNotificationId,
      foregroundServiceTypes: [AndroidForegroundType.dataSync],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: draftsBackgroundServiceOnStart,
      onBackground: _iosBackgroundNoop,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> _iosBackgroundNoop(ServiceInstance service) async => true;

Future<void> startDraftsBackgroundService() async {
  final service = FlutterBackgroundService();
  final running = await service.isRunning();
  if (running) return;
  await service.startService();
}

Future<void> stopDraftsBackgroundService() async {
  final service = FlutterBackgroundService();
  if (await service.isRunning()) {
    service.invoke('stop');
  }
}

@pragma('vm:entry-point')
Future<void> draftsBackgroundServiceOnStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    await service.setAsForegroundService();
    await service.setForegroundNotificationInfo(
      title: UiStrings.draftsSyncOngoingTitle,
      content: UiStrings.draftsSyncOngoingBody,
    );
  }

  final notifications = LocalNotificationService();
  await notifications.initialize();

  // Ensure ongoing channel exists (business channel created in LocalNotificationService).
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.draftsSyncNotificationChannelId,
          UiStrings.draftsSyncChannelName,
          description: UiStrings.draftsSyncChannelDescription,
          importance: Importance.low,
        ),
      );

  Timer? timer;
  var probing = false;

  Future<void> stopSelf() async {
    timer?.cancel();
    timer = null;
    await service.stopSelf();
  }

  service.on('stop').listen((_) {
    unawaited(stopSelf());
  });

  Future<void> probeOnce() async {
    if (probing) return;
    probing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final access = prefs.getString(AppConstants.keyAccessToken);
      final refresh = prefs.getString(AppConstants.keyRefreshToken);
      if (access == null ||
          access.isEmpty ||
          refresh == null ||
          refresh.isEmpty) {
        await stopSelf();
        return;
      }

      final tokenStorage = SharedPreferencesTokenStorage(prefs);
      final refresher = TokenRefresher(
        tokenStorage: tokenStorage,
        refreshDio: DioClient.createRefreshDio(),
      );
      final dio = DioClient.create(
        tokenStorage: tokenStorage,
        tokenRefresher: refresher,
      );
      final notes = NotesService(dio);

      var snapshot = await _store.load(prefs);
      final response = await notes.listNotes(
        type: 'DRAFT',
        page: 1,
        size: AppConstants.notesPageSize,
      );
      final data = response.data;
      if (!response.isSuccess || data == null) return;

      final pageIds = data.items.map((e) => e.note.id).toList();
      final titlesById = {
        for (final n in data.items) n.note.id: n.note.title,
      };
      final diff = snapshot.applyPage(pageIds: pageIds, total: data.total);
      snapshot = diff.next;
      await _store.save(prefs, snapshot);
      if (!diff.hasNewDrafts) return;

      final body = _notificationBody(diff, titlesById);
      await notifications.showDraftsUpdate(body: body);
      service.invoke('draftsUpdated');
    } on Object {
      // Spec: silent.
    } finally {
      probing = false;
    }
  }

  await probeOnce();
  timer = Timer.periodic(
    const Duration(seconds: AppConstants.draftsWatchIntervalSeconds),
    (_) => unawaited(probeOnce()),
  );
}

String _notificationBody(
  DraftsWatchDiff diff,
  Map<String, String?> titles,
) {
  if (diff.newIds.length == 1) {
    final t = titles[diff.newIds.first]?.trim();
    if (t != null && t.isNotEmpty) return t;
    return UiStrings.draftsNotificationUntitled;
  }
  return UiStrings.draftsNotificationMultiple(diff.notifyCount);
}
```

Notes for implementer:
- If `TokenRefresher.expireSession` clears tokens on refresh failure, calling it from the service isolate is OK; then `stopSelf()`.
- Prefer not scheduling proactive refresh timers forever in the service; constructing `TokenRefresher` per probe is fine, or construct once and `cancel()` in `stopSelf`.
- Do **not** import Riverpod here.

- [ ] **Step 2: Call initialize from main.dart**

In `main()` after `WidgetsFlutterBinding.ensureInitialized()` and before `runApp`, only configure on Android:

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'features/wechat/drafts_background_service.dart';

// inside main():
  if (!kIsWeb && Platform.isAndroid) {
    await initializeDraftsBackgroundService();
  }
```

Use a safe Platform check (guard `dart:io` behind conditional import if needed for Web compile). Preferred Web-safe pattern already used in many Flutter apps:

```dart
import 'package:flutter/foundation.dart';

Future<void> _initAndroidBackgroundService() async {
  if (kIsWeb) return;
  // ignore: avoid_web_libraries_in_flutter
  if (defaultTargetPlatform == TargetPlatform.android) {
    await initializeDraftsBackgroundService();
  }
}
```

Call `await _initAndroidBackgroundService();` from `main`.

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/features/wechat/drafts_background_service.dart lib/main.dart`  
Expected: No issues found (fix any API mismatches against installed package).

---

### Task 4: Coordinator lifecycle handoff + UI refresh bridge

**Files:**
- Modify: `lib/features/wechat/drafts_watch_coordinator.dart`
- Modify: `lib/app.dart` (`_DraftsWatchBootstrap`)

**Interfaces:**
- Consumes: `startDraftsBackgroundService`, `stopDraftsBackgroundService`, snapshot store
- Produces: Android pause → service; resume → main timer; logout still full `stop()`

- [ ] **Step 1: Split pause vs full stop in coordinator**

Add methods (names may match exactly):

```dart
  void pauseMainPollingForBackground() {
    _timer?.cancel();
    _timer = null;
    // Keep _snapshot; ensure persisted.
    unawaited(_persistSnapshot());
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      unawaited(startDraftsBackgroundService());
    }
  }

  void resumeMainPollingFromBackground() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      unawaited(stopDraftsBackgroundService());
    }
    if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
      start(immediateProbe: true);
    }
  }
```

Update `AppLifecycleListener`:

```dart
    _lifecycleListener = AppLifecycleListener(
      onDetach: stop,
      onPause: () {
        if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
          pauseMainPollingForBackground();
        }
      },
      onResume: () {
        if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
          resumeMainPollingFromBackground();
        }
      },
    );
```

Important:
- `stop()` (logout / dispose / detach) must also `unawaited(stopDraftsBackgroundService());` then clear snapshot prefs.
- Do **not** clear snapshot inside `pauseMainPollingForBackground`.
- Non-Android: `onPause` should be a no-op for service (optional: leave main Timer running as today).

- [ ] **Step 2: Bridge service → UI refresh in app.dart**

In `_DraftsWatchBootstrapState.initState` / post-frame, if Android:

```dart
  StreamSubscription? _draftsUpdatedSub;

  void _listenBackgroundDraftUpdates() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _draftsUpdatedSub =
        FlutterBackgroundService().on('draftsUpdated').listen((_) {
      unawaited(ref.read(draftsCountProvider.notifier).refresh());
      unawaited(ref.read(draftsListProvider.notifier).refresh());
    });
  }
```

Dispose subscription in `dispose`. Import service package + drafts providers.

- [ ] **Step 3: Analyze touched files**

Run:

```bash
flutter analyze lib/features/wechat/drafts_watch_coordinator.dart lib/features/wechat/drafts_background_service.dart lib/features/wechat/drafts_watch_snapshot_store.dart lib/app.dart lib/main.dart lib/core/constants/app_constants.dart lib/core/constants/ui_strings.dart
```

Expected: No issues found.

---

### Task 5: Full analyze + manual Android QA checklist

**Files:** none required (verification only); fix any analyze failures found.

- [x] **Step 1: Project analyze**

Run: `flutter analyze`  
Expected: No issues found (or only pre-existing unrelated issues — do not expand scope).

- [ ] **Step 2: Manual QA on a physical/emulated Android device** *(PENDING_USER — checklist in `.superpowers/sdd/task-5-report.md`)*

Use `flutter run -d <android-device>` (not Chrome). Checklist:

1. Login → stay foreground ~30s+ → probes continue; **no** ongoing「正在同步草稿」while resumed.
2. Press Home / switch app (do not swipe-away kill) → ongoing「正在同步草稿」appears.
3. Create a draft from another client/session → within ~30s system「新草稿」appears; tap opens `/drafts`.
4. Return to app → ongoing notification dismissed; badge/list reflects new draft.
5. Logout → ongoing gone; no further draft probes/notifications.
6. Kill process from recents → no requirement to keep notifying (A-tier).

- [x] **Step 3: Update design/plan status notes if needed**

Mark this plan’s task checkboxes done in the plan file when execution finishes. Do not commit unless the user asks.

---

## Spec coverage self-check

| Spec requirement | Task |
|------------------|------|
| Android FG service + dataSync | 1, 3 |
| ~30s REST poll in background | 3 |
| Ongoing「正在同步草稿」/ title「花森」 | 1, 3 |
| Business「新草稿」channel reused | 3 |
| Snapshot shared via SharedPreferences | 2, 3 |
| paused → start service; resumed → stop | 4 |
| Login foreground without FG service | 4 |
| Logout stops service + clears snapshot | 2, 4 |
| Token read/refresh in service isolate | 3 |
| No Riverpod in service isolate | 3 |
| Non-Android unchanged Timer | 4 |
| Manual QA list | 5 |
| No FCM/WebSocket/kill-process wake | Global constraints |

## Placeholder / consistency self-check

- Channel id locked: `drafts_sync` / `drafts_updates`.
- Event names locked: `stop`, `draftsUpdated`.
- Snapshot keys locked in `AppConstants`.
- `stop()` clears baseline; `pauseMainPollingForBackground()` does not.
