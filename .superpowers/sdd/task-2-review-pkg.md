# Review package — Task 2
Working tree (no commits). Scope: only these paths.

## Files
- lib/features/wechat/drafts_watch_snapshot_store.dart (new)
- lib/features/wechat/drafts_watch_coordinator.dart

## git status / diff --stat
 M lib/features/wechat/drafts_watch_coordinator.dart
?? lib/features/wechat/drafts_watch_snapshot_store.dart
 lib/features/wechat/drafts_watch_coordinator.dart | 38 +++++++++++++++++------
 1 file changed, 29 insertions(+), 9 deletions(-)

## Full file (new store)

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

## git diff -U10 coordinator

diff --git a/lib/features/wechat/drafts_watch_coordinator.dart b/lib/features/wechat/drafts_watch_coordinator.dart
index 6dd2ef5..9f4c43f 100644
--- a/lib/features/wechat/drafts_watch_coordinator.dart
+++ b/lib/features/wechat/drafts_watch_coordinator.dart
@@ -1,31 +1,33 @@
 import 'dart:async';
 
 import 'package:flutter/widgets.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:shared_preferences/shared_preferences.dart';
 
 import '../../core/constants/app_constants.dart';
 import '../../core/constants/ui_strings.dart';
 import '../../core/providers/core_providers.dart';
-import '../../core/router/app_router.dart';
 import '../auth/auth_notifier.dart';
 import '../auth/auth_state.dart';
 import 'drafts_count_provider.dart';
 import 'drafts_list_notifier.dart';
 import 'drafts_watch_snapshot.dart';
+import 'drafts_watch_snapshot_store.dart';
 
 /// Polls draft notes while authenticated and notifies when new drafts arrive.
 class DraftsWatchCoordinator extends Notifier<void> {
   Timer? _timer;
   DraftsWatchSnapshot _snapshot = const DraftsWatchSnapshot();
   bool _probing = false;
   AppLifecycleListener? _lifecycleListener;
+  final _snapshotStore = const DraftsWatchSnapshotStore();
 
   @override
   void build() {
     ref
       ..keepAlive()
       ..listen(authNotifierProvider, (prev, next) {
         if (next.status == AuthStatus.authenticated) {
           start();
         } else {
           stop();
@@ -41,81 +43,99 @@ class DraftsWatchCoordinator extends Notifier<void> {
       onDetach: stop,
       onResume: () {
         if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
           start(immediateProbe: true);
         }
       },
     );
   }
 
   void start({bool immediateProbe = true}) {
+    unawaited(_startAsync(immediateProbe: immediateProbe));
+  }
+
+  Future<void> _startAsync({required bool immediateProbe}) async {
+    await _loadSnapshot();
     _timer?.cancel();
     _timer = Timer.periodic(
       const Duration(seconds: AppConstants.draftsWatchIntervalSeconds),
       (_) => unawaited(probe()),
     );
     if (immediateProbe) {
-      unawaited(probe());
+      await probe();
     }
   }
 
   void stop() {
     _timer?.cancel();
     _timer = null;
     _snapshot = const DraftsWatchSnapshot();
+    unawaited(_clearSnapshotPrefs());
   }
 
   void onLocalDraftDeleted(String id) {
     _snapshot = _snapshot.afterLocalDelete(id);
+    unawaited(_persistSnapshot());
+  }
+
+  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();
+
+  Future<void> _persistSnapshot() async {
+    final prefs = await _prefs();
+    await _snapshotStore.save(prefs, _snapshot);
+  }
+
+  Future<void> _loadSnapshot() async {
+    final prefs = await _prefs();
+    _snapshot = await _snapshotStore.load(prefs);
+  }
+
+  Future<void> _clearSnapshotPrefs() async {
+    final prefs = await _prefs();
+    await _snapshotStore.clear(prefs);
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
+      await _persistSnapshot();
       if (!diff.hasNewDrafts) return;
 
       await ref.read(draftsCountProvider.notifier).refresh();
       await ref.read(draftsListProvider.notifier).refresh();
 
-      if (_isOnDraftsRoute()) return;
-
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
 
-  bool _isOnDraftsRoute() {
-    final loc = ref.read(routerProvider).state.matchedLocation;
-    return loc == AppConstants.routeDrafts;
-  }
-
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
