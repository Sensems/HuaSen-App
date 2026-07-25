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
  - Service 鈫?UI event name: `'draftsUpdated'`
  - UI 鈫?Service stop event: `'stop'`

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


