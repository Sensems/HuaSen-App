/// Formats a note's display time for the list card.
///
/// Prefers [updatedAt], falls back to [createdAt]. Returns empty string if both
/// are null. Uses Chinese relative labels for today/yesterday.
String formatNoteListTime(DateTime? updatedAt, DateTime? createdAt) {
  final t = updatedAt ?? createdAt;
  if (t == null) return '';
  final now = DateTime.now();
  final local = t.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diffDays = today.difference(day).inDays;
  final hm =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  if (diffDays == 0) return '今天 $hm';
  if (diffDays == 1) return '昨天 $hm';
  if (now.year == local.year) {
    return '${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hm';
  }
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
