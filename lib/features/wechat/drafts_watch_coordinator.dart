import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/providers/core_providers.dart';
import '../../core/router/app_router.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import 'drafts_count_provider.dart';
import 'drafts_list_notifier.dart';
import 'drafts_watch_snapshot.dart';

/// Polls draft notes while authenticated and notifies when new drafts arrive.
class DraftsWatchCoordinator extends Notifier<void> {
  Timer? _timer;
  DraftsWatchSnapshot _snapshot = const DraftsWatchSnapshot();
  bool _probing = false;
  AppLifecycleListener? _lifecycleListener;

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
      onResume: () {
        if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
          start(immediateProbe: true);
        }
      },
    );
  }

  void start({bool immediateProbe = true}) {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.draftsWatchIntervalSeconds),
      (_) => unawaited(probe()),
    );
    if (immediateProbe) {
      unawaited(probe());
    }
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

      final pageIds = data.items.map((e) => e.note.id).toList();
      final titlesById = {
        for (final n in data.items) n.note.id: n.note.title,
      };
      final diff = _snapshot.applyPage(pageIds: pageIds, total: data.total);
      _snapshot = diff.next;
      if (!diff.hasNewDrafts) return;

      await ref.read(draftsCountProvider.notifier).refresh();
      await ref.read(draftsListProvider.notifier).refresh();

      if (_isOnDraftsRoute()) return;

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

  bool _isOnDraftsRoute() {
    final loc = ref.read(routerProvider).state.matchedLocation;
    return loc == AppConstants.routeDrafts;
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
