import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesListQuery {
  const NotesListQuery({
    this.keyword = '',
    this.categoryId,
    this.tagIds = const [],
  });

  final String keyword;
  final String? categoryId;
  final List<String> tagIds;

  bool get hasCategoryTagFilter => categoryId != null || tagIds.isNotEmpty;

  NotesListQuery copyWith({
    String? keyword,
    String? categoryId,
    List<String>? tagIds,
    bool clearCategoryId = false,
  }) {
    return NotesListQuery(
      keyword: keyword ?? this.keyword,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      tagIds: tagIds ?? this.tagIds,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NotesListQuery &&
            keyword == other.keyword &&
            categoryId == other.categoryId &&
            _listEquals(tagIds, other.tagIds);
  }

  @override
  int get hashCode => Object.hash(keyword, categoryId, Object.hashAll(tagIds));
}

class NotesListQueryNotifier extends Notifier<NotesListQuery> {
  @override
  NotesListQuery build() => const NotesListQuery();

  void setKeyword(String keyword) {
    final trimmed = keyword.trim();
    if (state.keyword == trimmed) return;
    state = state.copyWith(keyword: trimmed);
  }

  void clearKeyword() {
    if (state.keyword.isEmpty) return;
    state = state.copyWith(keyword: '');
  }

  void setCategoryTagFilter({
    String? categoryId,
    List<String> tagIds = const [],
  }) {
    final nextTags = List<String>.from(tagIds);
    final sameCategory = state.categoryId == categoryId;
    final sameTags = _listEquals(state.tagIds, nextTags);
    if (sameCategory && sameTags) return;

    state = state.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
      tagIds: nextTags,
    );
  }
}

bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final notesListQueryProvider =
    NotifierProvider<NotesListQueryNotifier, NotesListQuery>(
  NotesListQueryNotifier.new,
);
