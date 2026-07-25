# Review package — Task 3
Working tree. Scope ONLY:
- lib/features/wechat/drafts_background_service.dart (new)
- lib/main.dart

## status
 M lib/main.dart
?? lib/features/wechat/drafts_background_service.dart

## NEW FILE drafts_background_service.dart

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

/// Configures the Android drafts foreground service (does not start it).
///
/// Must run on the main isolate before [runApp]. Creates the ongoing
/// notification channel first (required by `flutter_background_service` 5.x).
Future<void> initializeDraftsBackgroundService() async {
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

  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: draftsBackgroundServiceOnStart,
      autoStart: false,
      autoStartOnBoot: false,
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

/// Starts the drafts background service if it is not already running.
Future<void> startDraftsBackgroundService() async {
  final service = FlutterBackgroundService();
  final running = await service.isRunning();
  if (running) return;
  await service.startService();
}

/// Asks a running drafts background service to stop.
Future<void> stopDraftsBackgroundService() async {
  final service = FlutterBackgroundService();
  if (await service.isRunning()) {
    service.invoke('stop');
  }
}

/// Background isolate entry: probe drafts on an interval and notify on new ones.
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

  final prefs = await SharedPreferences.getInstance();
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

  Timer? timer;
  var probing = false;

  Future<void> stopSelf() async {
    timer?.cancel();
    timer = null;
    refresher.cancel();
    await service.stopSelf();
  }

  service.on('stop').listen((_) {
    unawaited(stopSelf());
  });

  Future<void> probeOnce() async {
    if (probing) return;
    probing = true;
    try {
      final access = prefs.getString(AppConstants.keyAccessToken);
      final refresh = prefs.getString(AppConstants.keyRefreshToken);
      if (access == null ||
          access.isEmpty ||
          refresh == null ||
          refresh.isEmpty) {
        await stopSelf();
        return;
      }

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

## git diff -U10 main.dart

diff --git a/lib/main.dart b/lib/main.dart
index 891f4c1..8bbb359 100644
--- a/lib/main.dart
+++ b/lib/main.dart
@@ -1,37 +1,49 @@
+import 'package:flutter/foundation.dart';
 import 'package:flutter/material.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
 import 'package:shared_preferences/shared_preferences.dart';
 
 import 'app.dart';
 import 'core/constants/app_constants.dart';
 import 'core/notifications/local_notification_service.dart';
 import 'core/providers/core_providers.dart';
 import 'features/auth/auth_notifier.dart';
+import 'features/wechat/drafts_background_service.dart';
 
 /// Entry point for sebhua_notes.
 ///
 /// Wraps the root [SebhuaNotesApp] in a [ProviderScope] so that every
 /// Riverpod provider in the widget tree has an owner container.
 Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   final prefs = await SharedPreferences.getInstance();
   final initialAuthStatus = initialAuthStatusFromStoredTokens(
     accessToken: prefs.getString(AppConstants.keyAccessToken),
     refreshToken: prefs.getString(AppConstants.keyRefreshToken),
     expiresAt: prefs.getInt(AppConstants.keyTokenExpiresAt),
   );
 
   final notificationService = LocalNotificationService();
   await notificationService.initialize();
 
+  await _initAndroidBackgroundService();
+
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
-}
\ No newline at end of file
+}
+
+/// Configures the drafts FG service on Android only (Web-safe; no `dart:io`).
+Future<void> _initAndroidBackgroundService() async {
+  if (kIsWeb) return;
+  if (defaultTargetPlatform == TargetPlatform.android) {
+    await initializeDraftsBackgroundService();
+  }
+}
