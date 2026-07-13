import '../../data/models/note_dtos.dart';

enum NotesFilterTab { all, pinned, recent }

class NotesListState {
  const NotesListState({
    this.items = const [],
    this.page = 0,
    this.total = 0,
    this.keyword = '',
    this.filterTab = NotesFilterTab.all,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError = false,
  });

  final List<NoteDetailDto> items;
  final int page;
  final int total;
  final String keyword;
  final NotesFilterTab filterTab;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool loadMoreError;

  bool get hasMore => items.length < total;

  NotesListState copyWith({
    List<NoteDetailDto>? items,
    int? page,
    int? total,
    String? keyword,
    NotesFilterTab? filterTab,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool? loadMoreError,
  }) {
    return NotesListState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      keyword: keyword ?? this.keyword,
      filterTab: filterTab ?? this.filterTab,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }
}
