### Task 4: Coordinator lifecycle handoff + UI refresh bridge

**Files:**
- Modify: `lib/features/wechat/drafts_watch_coordinator.dart`
- Modify: `lib/app.dart` (`_DraftsWatchBootstrap`)

**Interfaces:**
- Consumes: `startDraftsBackgroundService`, `stopDraftsBackgroundService`, snapshot store
- Produces: Android pause 鈫?service; resume 鈫?main timer; logout still full `stop()`

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

- [ ] **Step 2: Bridge service 鈫?UI refresh in app.dart**

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


