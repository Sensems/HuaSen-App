import '../../data/models/note_dtos.dart';

enum DraftsFilter { all, text, image, audio }

extension DraftsFilterMediaType on DraftsFilter {
  /// Query value for `listNotes(mediaType:)`. Null means omit the param.
  String? get mediaType => switch (this) {
        DraftsFilter.all => null,
        DraftsFilter.text => 'TEXT',
        DraftsFilter.image => 'IMAGE',
        DraftsFilter.audio => 'VOICE',
      };
}

class DraftsListState {
  const DraftsListState({
    this.items = const [],
    this.page = 0,
    this.total = 0,
    this.filter = DraftsFilter.all,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError = false,
  });

  final List<NoteDetailDto> items;
  final int page;
  final int total;
  final DraftsFilter filter;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool loadMoreError;

  bool get hasMore => items.length < total;

  DraftsListState copyWith({
    List<NoteDetailDto>? items,
    int? page,
    int? total,
    DraftsFilter? filter,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool? loadMoreError,
  }) {
    return DraftsListState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      filter: filter ?? this.filter,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }
}
