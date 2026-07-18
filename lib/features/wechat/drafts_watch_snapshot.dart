/// Immutable snapshot used by [DraftsWatchCoordinator] to detect new drafts.
class DraftsWatchSnapshot {
  const DraftsWatchSnapshot({
    this.knownIds = const {},
    this.knownTotal = 0,
    this.hasBaseline = false,
  });

  final Set<String> knownIds;
  final int knownTotal;
  final bool hasBaseline;

  DraftsWatchDiff applyPage({
    required List<String> pageIds,
    required int total,
  }) {
    final pageSet = pageIds.toSet();
    if (!hasBaseline) {
      return DraftsWatchDiff(
        next: DraftsWatchSnapshot(
          knownIds: pageSet,
          knownTotal: total,
          hasBaseline: true,
        ),
        establishedBaseline: true,
        hasNewDrafts: false,
        newIds: const [],
        notifyCount: 0,
      );
    }

    final newIds = pageSet.difference(knownIds).toList();
    final totalBump = total > knownTotal ? total - knownTotal : 0;
    final hasNew = newIds.isNotEmpty || totalBump > 0;
    if (!hasNew) {
      return DraftsWatchDiff(
        next: this,
        establishedBaseline: false,
        hasNewDrafts: false,
        newIds: const [],
        notifyCount: 0,
      );
    }

    final merged = {...knownIds, ...pageSet};
    final notifyCount = newIds.isNotEmpty ? newIds.length : totalBump;
    return DraftsWatchDiff(
      next: DraftsWatchSnapshot(
        knownIds: merged,
        knownTotal: total,
        hasBaseline: true,
      ),
      establishedBaseline: false,
      hasNewDrafts: true,
      newIds: newIds,
      notifyCount: notifyCount,
    );
  }

  DraftsWatchSnapshot afterLocalDelete(String id) {
    if (!hasBaseline) return this;
    final nextIds = {...knownIds}..remove(id);
    final nextTotal = knownTotal > 0 ? knownTotal - 1 : 0;
    return DraftsWatchSnapshot(
      knownIds: nextIds,
      knownTotal: nextTotal,
      hasBaseline: true,
    );
  }
}

class DraftsWatchDiff {
  const DraftsWatchDiff({
    required this.next,
    required this.establishedBaseline,
    required this.hasNewDrafts,
    required this.newIds,
    required this.notifyCount,
  });

  final DraftsWatchSnapshot next;
  final bool establishedBaseline;
  final bool hasNewDrafts;
  final List<String> newIds;
  final int notifyCount;
}
