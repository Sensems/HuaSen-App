# Re-review package after Important fixes
## drafts_watch_snapshot_store.dart
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'drafts_watch_snapshot.dart';

/// Persists [DraftsWatchSnapshot] for sharing between UI and background isolates.
class DraftsWatchSnapshotStore {
  const DraftsWatchSnapshotStore();

  Future<DraftsWatchSnapshot> load(SharedPreferences prefs) async {
    // Cross-isolate: SharedPreferences caches per isolate; reload disk writes
    // from the other isolate (main 鈫?background) before reading the snapshot.
    await prefs.reload();
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

## drafts_background_service.dart

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

## drafts_watch_coordinator.dart (full current)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/providers/core_providers.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import 'drafts_background_service.dart';
import 'drafts_count_provider.dart';
import 'drafts_list_notifier.dart';
import 'drafts_watch_snapshot.dart';
import 'drafts_watch_snapshot_store.dart';

/// Polls draft notes while authenticated and notifies when new drafts arrive.
class DraftsWatchCoordinator extends Notifier<void> {
  Timer? _timer;
  DraftsWatchSnapshot _snapshot = const DraftsWatchSnapshot();
  bool _probing = false;
  AppLifecycleListener? _lifecycleListener;
  final _snapshotStore = const DraftsWatchSnapshotStore();

  @override
  void build() {
    ref
      ..keepAlive()
      ..listen(authNotifierProvider, (prev, next) {
        if (next.status == AuthStatus.authenticated) {
          start();
        } else {
          stop();
        }
      }, fireImmediately: true)
      ..onDispose(() {
        _lifecycleListener?.dispose();
        _lifecycleListener = null;
        stop();
      });

    _lifecycleListener = AppLifecycleListener(
      onDetach: stop,
      onPause: () {
        // Android only: hand off to FG service. Other platforms keep the
        // main-isolate Timer running (no background service).
        if (!kIsWeb &&
            defaultTargetPlatform == TargetPlatform.android &&
            ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
          pauseMainPollingForBackground();
        }
      },
      onResume: () {
        if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
          resumeMainPollingFromBackground();
        }
      },
    );
  }

  /// Pauses the main-isolate timer and starts the Android FG service.
  ///
  /// Keeps the in-memory snapshot and persists it. Intended for Android
  /// `onPause` only 鈥?non-Android platforms should keep the main Timer.
  void pauseMainPollingForBackground() {
    _timer?.cancel();
    _timer = null;
    // Keep _snapshot; ensure persisted.
    unawaited(_persistSnapshot());
    unawaited(startDraftsBackgroundService());
  }

  /// Stops the Android foreground service (if any) and restarts main polling.
  void resumeMainPollingFromBackground() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      unawaited(stopDraftsBackgroundService());
    }
    if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
      start(immediateProbe: true);
    }
  }

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

  void stop() {
    _timer?.cancel();
    _timer = null;
    unawaited(stopDraftsBackgroundService());
    _snapshot = const DraftsWatchSnapshot();
    unawaited(_clearSnapshotPrefs());
  }

  void onLocalDraftDeleted(String id) {
    _snapshot = _snapshot.afterLocalDelete(id);
    unawaited(_persistSnapshot());
  }

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> _persistSnapshot() async {
    final prefs = await _prefs();
    await _snapshotStore.save(prefs, _snapshot);
  }

  Future<void> _loadSnapshot() async {
    final prefs = await _prefs();
    // Store.load also reloads; explicit reload here keeps call-site contract
    // for cross-isolate snapshot freshness on resume.
    await prefs.reload();
    _snapshot = await _snapshotStore.load(prefs);
  }

  Future<void> _clearSnapshotPrefs() async {
    final prefs = await _prefs();
    await _snapshotStore.clear(prefs);
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

      final pageIds = data.items.map((e) => e.note.id).toList();
      final titlesById = {
        for (final n in data.items) n.note.id: n.note.title,
      };
      final diff = _snapshot.applyPage(pageIds: pageIds, total: data.total);
      _snapshot = diff.next;
      await _persistSnapshot();
      if (!diff.hasNewDrafts) return;

      await ref.read(draftsCountProvider.notifier).refresh();
      await ref.read(draftsListProvider.notifier).refresh();

      final body = _notificationBody(diff, titlesById);
      await ref
          .read(localNotificationServiceProvider)
          .showDraftsUpdate(body: body);
    } on Object {
      // Spec: silent on probe errors.
    } finally {
      _probing = false;
    }
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
}

final draftsWatchProvider = NotifierProvider<DraftsWatchCoordinator, void>(
  DraftsWatchCoordinator.new,
);
