# Drafts Watch + Local Notify Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** While logged in and the app process is alive, poll drafts every ~30s; on new drafts refresh list/badge and show a system local notification unless the user is already on `/drafts`.

**Architecture:** KeepAlive `DraftsWatchCoordinator` (Riverpod) owns `Timer.periodic` + lifecycle; pure `DraftsWatchSnapshot` decides “new drafts”; `LocalNotificationService` wraps `flutter_local_notifications` (Web no-op). Auth start/stop; delete syncs snapshot.

**Tech Stack:** Flutter, Riverpod 3, Dio/`NotesService`, `flutter_local_notifications`, go_router, existing drafts list/count providers.

**Spec:** `docs/superpowers/specs/2026-07-16-drafts-watch-notify-design.md`

**Working directory for all Flutter commands:** repository root (`d:\lbs\demo\sebhua-notes-app`).

## Global Constraints

- Work only on `master`; do not create branches or git worktrees.
- No FCM / APNs / Workmanager / kill-process wake.
- No Drift / Repository.
- No automated tests this phase; verify with `flutter analyze` + manual QA.
- Poll interval ~30s via `AppConstants.draftsWatchIntervalSeconds`.
- Probe: `listNotes(type: 'DRAFT', page: 1, size: AppConstants.notesPageSize)` — same `type` string as `DraftsListNotifier`.
- On drafts route (`AppConstants.routeDrafts`): refresh only, never show notification.
- Web: poll + UI refresh OK; `LocalNotificationService.show` is no-op.
- Probe/notify failures: silent (no toast).
- Prefer Chinese copy in `UiStrings`; no hardcoded user-facing English for notifications.
- Commits only when the user explicitly asks (skip commit steps unless instructed).

---

## 〇、进度里程碑

| 项 | 内容 |
|----|------|
| 当前阶段 | 实施完成，待用户手动验收 |
| 完成度 | 6/6 |
| 状态 | ✅ 已完成 |

| 任务 | 说明 | 状态 |
|------|------|------|
| 4.1.1 | 依赖 + 常量 + 文案 | ✅ |
| 4.1.2 | `DraftsWatchSnapshot` 纯逻辑 | ✅ |
| 4.1.3 | `LocalNotificationService` + 平台权限 | ✅ |
| 4.1.4 | `DraftsWatchCoordinator` + 生命周期 | ✅ |
| 4.1.5 | Auth / 删除 / 路由接线 | ✅ |
| 4.1.6 | Analyze + 手动验收清单 | ✅ |

---

## UI / UX（系统通知，无新页面）

本功能**不新增业务页面**。用户可见面只有：

1. **系统通知**（Android / iOS / Windows / macOS）  
   - 标题：`新草稿`  
   - 单条 body：草稿 `title`，空则 `无标题`  
   - 多条 / 仅 total 增加：`有 N 条新草稿`  
   - Android channel 名：`草稿更新`（id: `drafts_updates`）  
   - 点击 → 进入 `/drafts`
2. **草稿 Tab 角标 / 列表** — 有新增时静默刷新（已有 UI）
3. **正停留在草稿箱** — 只刷新，不弹通知

无设置开关、无应用内 banner（本轮）。

---

## File structure

| File | Responsibility |
|------|----------------|
| `pubspec.yaml` | Add `flutter_local_notifications` |
| `lib/core/constants/app_constants.dart` | Interval, Android channel id |
| `lib/core/constants/ui_strings.dart` | Notification / channel copy |
| `lib/features/wechat/drafts_watch_snapshot.dart` | Pure baseline + diff (no Flutter) |
| `lib/core/notifications/local_notification_service.dart` | Init / permission / show / tap callback |
| `lib/core/providers/core_providers.dart` | `localNotificationServiceProvider` |
| `lib/features/wechat/drafts_watch_coordinator.dart` | Timer, lifecycle, probe, refresh, notify |
| `lib/features/wechat/drafts_list_notifier.dart` | On delete → notify coordinator snapshot |
| `lib/main.dart` | Init notifications before `runApp` |
| `lib/app.dart` | Ensure coordinator is watched when authenticated (or wire via Auth) |
| `android/app/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` if required |
| iOS `Info.plist` | Only if plugin docs require extra keys for alerts |

Reuse: `notesServiceProvider`, `draftsListProvider`, `draftsCountProvider`, `authNotifierProvider`, `routerProvider`, `AppConstants.routeDrafts`.

---

### Task 1: Dependency, constants, copy (4.1.1) ✅

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/core/constants/app_constants.dart`
- Modify: `lib/core/constants/ui_strings.dart`

**Interfaces:**
- Produces:
  - `AppConstants.draftsWatchIntervalSeconds` → `30`
  - `AppConstants.draftsNotificationChannelId` → `'drafts_updates'`
  - UiStrings keys below

- [ ] **Step 1: Add dependency**

In `pubspec.yaml` `dependencies:` add (use current stable compatible with SDK ^3.12):

```yaml
  flutter_local_notifications: ^19.4.0
```

If `flutter pub get` resolves a different latest ^19/^18 that fits the SDK, pin that resolved version — do not add unrelated packages (`timezone` only if the plugin version requires it for *immediate* notifications; prefer not adding if unused).

- [ ] **Step 2: `flutter pub get`**

Run: `flutter pub get`  
Expected: exit 0.

- [ ] **Step 3: Constants**

Append to `AppConstants` (near networking / notes section):

```dart
  /// Polling interval for draft watch while the app process is alive.
  static const int draftsWatchIntervalSeconds = 30;

  /// Android notification channel id for draft updates.
  static const String draftsNotificationChannelId = 'drafts_updates';
```

- [ ] **Step 4: UiStrings**

Append under Drafts screen section:

```dart
  static const String draftsNotificationChannelName = '草稿更新';
  static const String draftsNotificationChannelDescription = '有新的微信/同步草稿时提醒';
  static const String draftsNotificationTitle = '新草稿';
  static const String draftsNotificationUntitled = '无标题';
  static const String draftsNotificationMultiplePrefix = '有';
  static const String draftsNotificationMultipleSuffix = '条新草稿';
```

Helper for multiple (can live on UiStrings or inline in service later):

```dart
  static String draftsNotificationMultiple(int count) =>
      '$draftsNotificationMultiplePrefix$count$draftsNotificationMultipleSuffix';
```

- [ ] **Step 5: Analyze constants**

Run: `dart analyze lib/core/constants/app_constants.dart lib/core/constants/ui_strings.dart`  
Expected: no issues.

---

### Task 2: Pure snapshot diff (4.1.2) ✅

**Files:**
- Create: `lib/features/wechat/drafts_watch_snapshot.dart`

**Interfaces:**
- Produces:
  - `class DraftsWatchSnapshot` with `Set<String> knownIds`, `int knownTotal`, `bool hasBaseline`
  - `DraftsWatchDiff applyPage({required List<String> pageIds, required int total})`
  - `DraftsWatchDiff` fields: `DraftsWatchSnapshot next`, `bool establishedBaseline`, `bool hasNewDrafts`, `List<String> newIds`, `int notifyCount`
  - `DraftsWatchSnapshot afterLocalDelete(String id)`

**Logic (must match spec):**

```dart
/// Immutable snapshot used by [DraftsWatchCoordinator] to detect new drafts.
class DraftsWatchSnapshot {
  const DraftsWatchSnapshot({
    this.knownIds = const {},
    this.knownTotal = 0,
    this.hasBaseline = false,
  });

  final Set<String> knownIds;
  final int knownTotal;
  final bool hasBaseline;

  DraftsWatchDiff applyPage({
    required List<String> pageIds,
    required int total,
  }) {
    final pageSet = pageIds.toSet();
    if (!hasBaseline) {
      return DraftsWatchDiff(
        next: DraftsWatchSnapshot(
          knownIds: pageSet,
          knownTotal: total,
          hasBaseline: true,
        ),
        establishedBaseline: true,
        hasNewDrafts: false,
        newIds: const [],
        notifyCount: 0,
      );
    }

    final newIds = pageSet.difference(knownIds).toList();
    final totalBump = total > knownTotal ? total - knownTotal : 0;
    final hasNew = newIds.isNotEmpty || totalBump > 0;
    if (!hasNew) {
      return DraftsWatchDiff(
        next: this,
        establishedBaseline: false,
        hasNewDrafts: false,
        newIds: const [],
        notifyCount: 0,
      );
    }

    final merged = {...knownIds, ...pageSet};
    final notifyCount = newIds.isNotEmpty ? newIds.length : totalBump;
    return DraftsWatchDiff(
      next: DraftsWatchSnapshot(
        knownIds: merged,
        knownTotal: total,
        hasBaseline: true,
      ),
      establishedBaseline: false,
      hasNewDrafts: true,
      newIds: newIds,
      notifyCount: notifyCount,
    );
  }

  DraftsWatchSnapshot afterLocalDelete(String id) {
    if (!hasBaseline) return this;
    final nextIds = {...knownIds}..remove(id);
    final nextTotal = knownTotal > 0 ? knownTotal - 1 : 0;
    return DraftsWatchSnapshot(
      knownIds: nextIds,
      knownTotal: nextTotal,
      hasBaseline: true,
    );
  }
}

class DraftsWatchDiff {
  const DraftsWatchDiff({
    required this.next,
    required this.establishedBaseline,
    required this.hasNewDrafts,
    required this.newIds,
    required this.notifyCount,
  });

  final DraftsWatchSnapshot next;
  final bool establishedBaseline;
  final bool hasNewDrafts;
  final List<String> newIds;
  final int notifyCount;
}
```

- [ ] **Step 1: Create the file** with the code above (adjust only for lint / style consistency).

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/features/wechat/drafts_watch_snapshot.dart`  
Expected: no issues.

---

### Task 3: LocalNotificationService + platform bits (4.1.3) ✅

**Files:**
- Create: `lib/core/notifications/local_notification_service.dart`
- Modify: `lib/core/providers/core_providers.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `lib/main.dart` (init call only; tap wiring may complete in Task 5)

**Interfaces:**
- Produces:
  - `class LocalNotificationService`
    - `Future<void> initialize({void Function(String? payload)? onSelect})`
    - `Future<void> requestPermission()`
    - `Future<void> showDraftsUpdate({required String body, String? payload})`
  - `final localNotificationServiceProvider = Provider<LocalNotificationService>(...)`
  - On Web (`kIsWeb`): all methods no-op successfully
  - Payload for drafts navigation: `AppConstants.routeDrafts` or literal `'drafts'` — **use `AppConstants.routeDrafts`**

- [ ] **Step 1: Implement service**

```dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_constants.dart';
import '../constants/ui_strings.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin].
///
/// Web: all methods are no-ops. Desktop/mobile: system notifications.
class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  void Function(String? payload)? _onSelect;

  Future<void> initialize({void Function(String? payload)? onSelect}) async {
    _onSelect = onSelect;
    if (kIsWeb) {
      _ready = true;
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
      // Windows: follow plugin docs for the installed version; if the
      // InitializationSettings constructor requires windows:, add
      // WindowsInitializationSettings with app name/guid per plugin README.
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _onSelect?.call(response.payload);
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.draftsNotificationChannelId,
        UiStrings.draftsNotificationChannelName,
        description: UiStrings.draftsNotificationChannelDescription,
        importance: Importance.defaultImportance,
      ),
    );

    _ready = true;
  }

  Future<void> requestPermission() async {
    if (kIsWeb || !_ready) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final mac = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await mac?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showDraftsUpdate({
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || !_ready) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.draftsNotificationChannelId,
        UiStrings.draftsNotificationChannelName,
        channelDescription: UiStrings.draftsNotificationChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.show(
        /* id */ DateTime.now().millisecondsSinceEpoch ~/ 1000,
        UiStrings.draftsNotificationTitle,
        body,
        details,
        payload: payload ?? AppConstants.routeDrafts,
      );
    } on Object {
      // Spec: silent on show failure.
    }
  }
}
```

**Implementer notes:**
- Do **not** import `dart:io` on Web builds — guard with `kIsWeb` and avoid `Platform` if it breaks web compile. Prefer `defaultTargetPlatform` / plugin resolve APIs only (remove unused `Platform` import if present).
- Match exact `InitializationSettings` / `show` API of the resolved plugin version from Context7 or package README; adjust constructor args if the version differs (especially Windows).
- Linux: if plugin unsupported, catch and no-op inside `initialize`/`show`.

- [ ] **Step 2: Provider**

In `core_providers.dart`:

```dart
import '../notifications/local_notification_service.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});
```

- [ ] **Step 3: Android permission**

In `android/app/src/main/AndroidManifest.xml`, inside `<manifest>` (sibling of `<application>`):

```xml
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

- [ ] **Step 4: Analyze**

Run: `dart analyze lib/core/notifications/local_notification_service.dart lib/core/providers/core_providers.dart`  
Expected: no issues (fix Windows init if analyzer complains).

---

### Task 4: DraftsWatchCoordinator (4.1.4) ✅

**Files:**
- Create: `lib/features/wechat/drafts_watch_coordinator.dart`

**Interfaces:**
- Consumes: `DraftsWatchSnapshot`, `notesServiceProvider`, `draftsListProvider`, `draftsCountProvider`, `localNotificationServiceProvider`, `authNotifierProvider` (or auth status), router matched location getter
- Produces:
  - `class DraftsWatchCoordinator extends Notifier<void>` (or `Notifier<DraftsWatchSnapshot>` if useful)
  - `void start()` / `void stop()` / `void onLocalDraftDeleted(String id)`
  - `Future<void> probe()` (public for lifecycle immediate probe)
  - `final draftsWatchProvider = NotifierProvider<DraftsWatchCoordinator, void>(...)` with `keepAlive: true` via `@Riverpod(keepAlive: true)` **or** manual `NotifierProvider` + `ref.keepAlive()` in `build`

**Behavior:**

```dart
// Pseudocode — expand to full Dart in implementation.

@override
void build() {
  ref.keepAlive();
  // Listen auth:
  ref.listen(authNotifierProvider, (prev, next) {
    if (next.status == AuthStatus.authenticated) {
      start();
    } else {
      stop();
    }
  }, fireImmediately: true);

  final binding = WidgetsBinding.instance;
  late final AppLifecycleListener listener;
  listener = AppLifecycleListener(
    onDetach: stop,
    onResume: () {
      if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
        start(immediateProbe: true);
      }
    },
    // paused: do NOT stop (spec)
  );
  ref.onDispose(() {
    listener.dispose();
    stop();
  });
}

void start({bool immediateProbe = true}) {
  _timer?.cancel();
  _timer = Timer.periodic(
    Duration(seconds: AppConstants.draftsWatchIntervalSeconds),
    (_) => unawaited(probe()),
  );
  if (immediateProbe) unawaited(probe());
}

void stop() {
  _timer?.cancel();
  _timer = null;
  _snapshot = const DraftsWatchSnapshot();
}

void onLocalDraftDeleted(String id) {
  _snapshot = _snapshot.afterLocalDelete(id);
}

Future<void> probe() async {
  if (_probing) return;
  _probing = true;
  try {
    final response = await ref.read(notesServiceProvider).listNotes(
      type: 'DRAFT',
      page: 1,
      size: AppConstants.notesPageSize,
    );
    final data = response.data;
    if (!response.isSuccess || data == null) return;

    final pageIds = data.items.map((e) => e.id).toList();
    final titlesById = {
      for (final n in data.items) n.id: n.title,
    };
    final diff = _snapshot.applyPage(pageIds: pageIds, total: data.total);
    _snapshot = diff.next;
    if (!diff.hasNewDrafts) return;

    await ref.read(draftsCountProvider.notifier).refresh();
    await ref.read(draftsListProvider.notifier).refresh();

    if (_isOnDraftsRoute()) return;

    final body = _notificationBody(diff, titlesById);
    await ref.read(localNotificationServiceProvider).showDraftsUpdate(body: body);
  } on Object {
    // silent
  } finally {
    _probing = false;
  }
}

bool _isOnDraftsRoute() {
  // Prefer GoRouter: ref.read(routerProvider).state.uri.path
  // or matchedLocation — must equal AppConstants.routeDrafts
  final loc = ref.read(routerProvider).state.matchedLocation;
  return loc == AppConstants.routeDrafts;
}

String _notificationBody(DraftsWatchDiff diff, Map<String, String?> titles) {
  if (diff.newIds.length == 1) {
    final t = titles[diff.newIds.first]?.trim();
    if (t != null && t.isNotEmpty) return t;
    return UiStrings.draftsNotificationUntitled;
  }
  return UiStrings.draftsNotificationMultiple(diff.notifyCount);
}
```

**Important:**
- `refresh()` on drafts list currently returns `true` early if already refreshing — OK.
- Do not toast on probe errors.
- First successful probe establishes baseline without notify (`establishedBaseline`).

- [ ] **Step 1: Implement coordinator file** fully (not pseudocode).

- [ ] **Step 2: Analyze**

Run: `dart analyze lib/features/wechat/drafts_watch_coordinator.dart`  
Expected: no issues.

---

### Task 5: Wire auth, main, delete, notification tap (4.1.5) ✅

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/app.dart` (or `SebhuaNotesApp`)
- Modify: `lib/features/wechat/drafts_list_notifier.dart` (`deleteDraft`)
- Possibly: `lib/core/router/app_router.dart` only if a navigator key is required

**Interfaces:**
- Consumes: `localNotificationServiceProvider`, `draftsWatchProvider`, `routerProvider`
- Produces: notifications initialized; tap → `router.go(AppConstants.routeDrafts)`; delete updates snapshot

- [ ] **Step 1: Initialize notifications in `main`**

After `WidgetsFlutterBinding.ensureInitialized()` and prefs load, **before** `runApp`, you cannot easily use Riverpod. Pattern:

```dart
final notificationService = LocalNotificationService();
await notificationService.initialize();
// requestPermission can be deferred until first authenticated frame

runApp(
  ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      initialAuthStatusProvider.overrideWithValue(initialAuthStatus),
      localNotificationServiceProvider.overrideWithValue(notificationService),
    ],
    child: const SebhuaNotesApp(),
  ),
);
```

Then in `SebhuaNotesApp.build` (or a tiny `ConsumerStatefulWidget` child):

```dart
ref.listen(authNotifierProvider, (prev, next) {
  if (next.status == AuthStatus.authenticated) {
    unawaited(ref.read(localNotificationServiceProvider).requestPermission());
  }
});
// Keep coordinator alive:
ref.watch(draftsWatchProvider);
```

Set tap handler once coordinator/router exist — either:

1. In `initialize(onSelect: ...)` pass a callback that uses a top-level `ProviderContainer` / late `GoRouter`, **or**
2. Re-assign in app after first frame:

```dart
// LocalNotificationService should allow setting onSelect after init:
notificationService.setOnSelect((payload) {
  if (payload == AppConstants.routeDrafts || payload == 'drafts') {
    ref.read(routerProvider).go(AppConstants.routeDrafts);
  }
});
```

Add `setOnSelect` if not present in Task 3.

- [ ] **Step 2: Sync delete**

In `DraftsListNotifier.deleteDraft`, after successful local list update:

```dart
ref.read(draftsWatchProvider.notifier).onLocalDraftDeleted(id);
```

(If provider state type is `void`, still expose `onLocalDraftDeleted` on the notifier.)

- [ ] **Step 3: Avoid double-listen conflicts**

Auth listen should live **either** in coordinator `build` **or** in app — not both starting duplicate timers. Prefer **only coordinator** listens to auth + lifecycle; app only `watch`es provider + permission + tap.

- [ ] **Step 4: Analyze touched files**

Run: `flutter analyze lib/main.dart lib/app.dart lib/features/wechat/drafts_list_notifier.dart lib/features/wechat/drafts_watch_coordinator.dart lib/core/notifications/`  
Expected: no issues.

---

### Task 6: Verification (4.1.6) ✅

**Files:** none (QA)

- [x] **Step 1: Full analyze**

Run: `flutter analyze`  
Expected: no issues (or only pre-existing unrelated infos — do not leave new errors).

- [ ] **Step 2: Manual QA checklist** — PENDING_USER

| # | Steps | Expected | Status |
|---|-------|----------|--------|
| 1 | Login on Android/Windows; wait ≤30s; create draft via another session/API | Off `/drafts`: system notification + badge/list update | PENDING_USER |
| 2 | Stay on 草稿箱; create another draft remotely | List/badge update; **no** notification | PENDING_USER |
| 3 | Logout | No further probes/notifications | PENDING_USER |
| 4 | Login; background app (do not kill); create draft | Notification within reasonable delay | PENDING_USER |
| 5 | Chrome web | Probe/refresh OK; no crash; no system notification required | PENDING_USER |
| 6 | Deny notification permission (mobile) | Still refreshes list/badge; no crash | PENDING_USER |

- [x] **Step 3: Update milestones**

In this plan file and `.cursor/plan/drafts-watch-notify.md`, mark tasks `[x]`, set 完成度 `6/6`, 状态 `✅ 已完成`.

---

## 实现调整

（实施中若有与计划不符的必要变更，记在此处。）

---

## Spec coverage check

| Spec requirement | Task |
|------------------|------|
| 30s in-process poll | 1, 4 |
| New drafts only (ids / total bump) | 2, 4 |
| Silent on drafts route | 4 |
| Local notifications mobile/desktop | 3, 5 |
| Web silent / no system notify | 3 |
| Auth start/stop + lifecycle | 4, 5 |
| Baseline no notify | 2, 4 |
| Local delete snapshot sync | 5 |
| Tap → `/drafts` | 5 |
| Manual QA | 6 |
| No FCM / kill-process | Global constraints |

---

## Execution handoff

Plan complete. After user approval to implement:

1. **Subagent-Driven (recommended per AGENTS.md)** — `subagent-driven-development`, one subagent per task, review between tasks  
2. **Inline in this session** — only if user explicitly overrides  

Do not start implementation until the user chooses.
