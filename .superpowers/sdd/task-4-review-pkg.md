# Review package — Task 4
Scope ONLY:
- lib/features/wechat/drafts_watch_coordinator.dart
- lib/app.dart

## status
 M lib/app.dart
 M lib/features/wechat/drafts_watch_coordinator.dart

## git diff -U10

diff --git a/lib/app.dart b/lib/app.dart
index bc92a5c..30fb3f3 100644
--- a/lib/app.dart
+++ b/lib/app.dart
@@ -1,22 +1,26 @@
 import 'dart:async';
 
+import 'package:flutter/foundation.dart';
 import 'package:flutter/material.dart';
+import 'package:flutter_background_service/flutter_background_service.dart';
 import 'package:flutter_localizations/flutter_localizations.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
 import 'package:tolyui_message/tolyui_message.dart';
 
 import 'core/constants/app_constants.dart';
 import 'core/providers/core_providers.dart';
 import 'core/router/app_router.dart';
 import 'features/auth/auth_notifier.dart';
 import 'features/auth/auth_state.dart';
+import 'features/wechat/drafts_count_provider.dart';
+import 'features/wechat/drafts_list_notifier.dart';
 import 'features/wechat/drafts_watch_coordinator.dart';
 import 'ui/theme/app_theme.dart';
 import 'ui/theme/theme_provider.dart';
 
 /// Root widget for sebhua_notes.
 ///
 /// Wraps [MaterialApp.router] with a [GoRouter] provided by
 /// [routerProvider] and applies the light/dark [ThemeData] from
 /// [AppTheme] based on the current [ThemeMode] held in
 /// [themeModeProvider].
@@ -75,31 +79,50 @@ class _DraftsWatchBootstrap extends ConsumerStatefulWidget {
 
   @override
   ConsumerState<_DraftsWatchBootstrap> createState() =>
       _DraftsWatchBootstrapState();
 }
 
 class _DraftsWatchBootstrapState extends ConsumerState<_DraftsWatchBootstrap> {
   bool _permissionRequested = false;
   bool _tapHandlerSet = false;
   bool _launchNavigationHandled = false;
+  StreamSubscription<Map<String, dynamic>?>? _draftsUpdatedSub;
 
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (!mounted) return;
       _requestPermissionIfAuthenticated(ref.read(authNotifierProvider));
       unawaited(_handleColdStartNotificationLaunch());
+      _listenBackgroundDraftUpdates();
     });
   }
 
+  void _listenBackgroundDraftUpdates() {
+    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
+    _draftsUpdatedSub?.cancel();
+    _draftsUpdatedSub =
+        FlutterBackgroundService().on('draftsUpdated').listen((_) {
+      unawaited(ref.read(draftsCountProvider.notifier).refresh());
+      unawaited(ref.read(draftsListProvider.notifier).refresh());
+    });
+  }
+
+  @override
+  void dispose() {
+    _draftsUpdatedSub?.cancel();
+    _draftsUpdatedSub = null;
+    super.dispose();
+  }
+
   Future<void> _handleColdStartNotificationLaunch() async {
     final payload =
         await ref.read(localNotificationServiceProvider).pendingLaunchPayload();
     if (!mounted) return;
     _goToDraftsIfPayload(payload);
   }
 
   bool _isDraftsPayload(String? payload) {
     return payload == AppConstants.routeDrafts || payload == 'drafts';
   }
diff --git a/lib/features/wechat/drafts_watch_coordinator.dart b/lib/features/wechat/drafts_watch_coordinator.dart
index 6dd2ef5..c9bd4d8 100644
--- a/lib/features/wechat/drafts_watch_coordinator.dart
+++ b/lib/features/wechat/drafts_watch_coordinator.dart
@@ -1,121 +1,173 @@
 import 'dart:async';
 
+import 'package:flutter/foundation.dart';
 import 'package:flutter/widgets.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:shared_preferences/shared_preferences.dart';
 
 import '../../core/constants/app_constants.dart';
 import '../../core/constants/ui_strings.dart';
 import '../../core/providers/core_providers.dart';
-import '../../core/router/app_router.dart';
 import '../auth/auth_notifier.dart';
 import '../auth/auth_state.dart';
+import 'drafts_background_service.dart';
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
         }
       }, fireImmediately: true)
       ..onDispose(() {
         _lifecycleListener?.dispose();
         _lifecycleListener = null;
         stop();
       });
 
     _lifecycleListener = AppLifecycleListener(
       onDetach: stop,
+      onPause: () {
+        if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
+          pauseMainPollingForBackground();
+        }
+      },
       onResume: () {
         if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
-          start(immediateProbe: true);
+          resumeMainPollingFromBackground();
         }
       },
     );
   }
 
+  /// Pauses the main-isolate timer for background handoff.
+  ///
+  /// Keeps the in-memory snapshot and persists it. On Android, starts the
+  /// foreground service; on other platforms the service start is a no-op.
+  void pauseMainPollingForBackground() {
+    _timer?.cancel();
+    _timer = null;
+    // Keep _snapshot; ensure persisted.
+    unawaited(_persistSnapshot());
+    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
+      unawaited(startDraftsBackgroundService());
+    }
+  }
+
+  /// Stops the Android foreground service (if any) and restarts main polling.
+  void resumeMainPollingFromBackground() {
+    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
+      unawaited(stopDraftsBackgroundService());
+    }
+    if (ref.read(authNotifierProvider).status == AuthStatus.authenticated) {
+      start(immediateProbe: true);
+    }
+  }
+
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
+    unawaited(stopDraftsBackgroundService());
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
