import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/providers/core_providers.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import 'android_os.dart';
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
        if (isAndroidOperatingSystem &&
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
  /// `onPause` only — non-Android platforms should keep the main Timer.
  void pauseMainPollingForBackground() {
    _timer?.cancel();
    _timer = null;
    // Keep _snapshot; ensure persisted.
    unawaited(_persistSnapshot());
    unawaited(startDraftsBackgroundService());
  }

  /// Stops the Android foreground service (if any) and restarts main polling.
  void resumeMainPollingFromBackground() {
    if (isAndroidOperatingSystem) {
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
