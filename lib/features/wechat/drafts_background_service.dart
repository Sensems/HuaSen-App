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
import 'android_os.dart';
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
  if (!isAndroidOperatingSystem) return;
  final service = FlutterBackgroundService();
  final running = await service.isRunning();
  if (running) return;
  await service.startService();
}

/// Asks a running drafts background service to stop.
Future<void> stopDraftsBackgroundService() async {
  if (!isAndroidOperatingSystem) return;
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

  // Refresh failure / session expiry must stop FG service immediately
  // (do not wait for the next 30s tick).
  refresher
    ..onSessionExpired = () {
      unawaited(stopSelf());
    }
    ..scheduleProactiveRefresh();

  service.on('stop').listen((_) {
    unawaited(stopSelf());
  });

  Future<bool> hasAuthTokens() async {
    await prefs.reload();
    final access = prefs.getString(AppConstants.keyAccessToken);
    final refresh = prefs.getString(AppConstants.keyRefreshToken);
    return access != null &&
        access.isNotEmpty &&
        refresh != null &&
        refresh.isNotEmpty;
  }

  Future<void> probeOnce() async {
    if (probing) return;
    probing = true;
    try {
      if (!await hasAuthTokens()) {
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
      if (!response.isSuccess || data == null) {
        // AuthInterceptor/TokenRefresher may clear tokens without throwing
        // a typed error; stop immediately if unauthenticated after the attempt.
        if (!await hasAuthTokens()) {
          await stopSelf();
        }
        return;
      }

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
      // Spec: silent on probe errors; stop only when auth tokens are gone.
      if (!await hasAuthTokens()) {
        await stopSelf();
      }
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
