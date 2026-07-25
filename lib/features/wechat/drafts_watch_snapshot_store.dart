import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'drafts_watch_snapshot.dart';

/// Persists [DraftsWatchSnapshot] for sharing between UI and background isolates.
class DraftsWatchSnapshotStore {
  const DraftsWatchSnapshotStore();

  Future<DraftsWatchSnapshot> load(SharedPreferences prefs) async {
    // Cross-isolate: SharedPreferences caches per isolate; reload disk writes
    // from the other isolate (main ↔ background) before reading the snapshot.
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
