### Task 2: Snapshot SharedPreferences store

**Files:**
- Create: `lib/features/wechat/drafts_watch_snapshot_store.dart`
- Modify: `lib/features/wechat/drafts_watch_coordinator.dart` (persist on snapshot changes / load on start / clear on stop)
- Modify: `lib/features/wechat/drafts_list_notifier.dart` only if delete path must also persist (prefer store calls inside coordinator `onLocalDraftDeleted`)

**Interfaces:**
- Consumes: `DraftsWatchSnapshot`, `AppConstants` keys, `SharedPreferences`
- Produces:
  - `class DraftsWatchSnapshotStore`
  - `Future<DraftsWatchSnapshot> load(SharedPreferences prefs)`
  - `Future<void> save(SharedPreferences prefs, DraftsWatchSnapshot snapshot)`
  - `Future<void> clear(SharedPreferences prefs)`
  - Known ids stored as comma-separated string (ids are UUIDs without commas)

- [ ] **Step 1: Create store**

```dart
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
```

- [ ] **Step 2: Wire coordinator memory ↔ prefs**

In `DraftsWatchCoordinator`:

1. Add `final _snapshotStore = const DraftsWatchSnapshotStore();`
2. After every assignment to `_snapshot` that changes baseline (probe success, `onLocalDraftDeleted`, `stop` clear), call:
   `unawaited(_persistSnapshot());`
3. Implement:

```dart
  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> _persistSnapshot() async {
    final prefs = await _prefs();
    await _snapshotStore.save(prefs, _snapshot);
  }

  Future<void> _loadSnapshot() async {
    final prefs = await _prefs();
    _snapshot = await _snapshotStore.load(prefs);
  }

  Future<void> _clearSnapshotPrefs() async {
    final prefs = await _prefs();
    await _snapshotStore.clear(prefs);
  }
```

4. At the beginning of `start({bool immediateProbe = true})`, `await _loadSnapshot()` (make `start` async or kick `unawaited(_startAsync(...))` so load completes before first probe). Preferred pattern:

```dart
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
```

5. In `stop()`: cancel timer; `_snapshot = const DraftsWatchSnapshot();` then `unawaited(_clearSnapshotPrefs());`

6. In `probe()` after `_snapshot = diff.next;`, `await _persistSnapshot();` before early return / notify.

7. In `onLocalDraftDeleted`: update `_snapshot` then `unawaited(_persistSnapshot());`

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/features/wechat/drafts_watch_snapshot_store.dart lib/features/wechat/drafts_watch_coordinator.dart`  
Expected: No issues found.

**Do NOT** yet add pause/resume FG service handoff (Task 4). Keep existing AppLifecycleListener behavior for now.
