import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import 'notes_list_state.dart';

class NotesListNotifier extends Notifier<NotesListState> {
  @override
  NotesListState build() => const NotesListState();

  /// Loads page 1. Call from the screen on first frame (not from [build]).
  Future<void> loadInitial() async {
    if (state.isInitialLoading) return;
    state = state.copyWith(
      isInitialLoading: true,
      clearError: true,
      loadMoreError: false,
    );
    await _fetchPage(page: 1, replace: true);
  }

  /// Pull-to-refresh: page 1 replace. Returns `false` on failure (list kept).
  Future<bool> refresh() async {
    if (state.isRefreshing || state.isInitialLoading) return true;
    state = state.copyWith(isRefreshing: true, loadMoreError: false);
    return _fetchPage(page: 1, replace: true, isRefresh: true);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.isInitialLoading ||
        state.isRefreshing ||
        !state.hasMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, loadMoreError: false);
    await _fetchPage(page: state.page + 1, replace: false);
  }

  Future<void> search(String keyword) async {
    state = state.copyWith(
      keyword: keyword.trim(),
      isInitialLoading: true,
      clearError: true,
      loadMoreError: false,
    );
    await _fetchPage(page: 1, replace: true);
  }

  Future<void> clearSearch() async {
    if (state.keyword.isEmpty) return;
    state = state.copyWith(
      keyword: '',
      isInitialLoading: true,
      clearError: true,
      loadMoreError: false,
    );
    await _fetchPage(page: 1, replace: true);
  }

  Future<void> setFilter(NotesFilterTab tab) async {
    if (state.filterTab == tab) return;
    state = state.copyWith(
      filterTab: tab,
      items: const [],
      page: 0,
      total: 0,
      isInitialLoading: true,
      clearError: true,
      loadMoreError: false,
    );
    await _fetchPage(page: 1, replace: true);
  }

  Future<void> retry() => loadInitial();

  Future<bool> _fetchPage({
    required int page,
    required bool replace,
    bool isRefresh = false,
  }) async {
    if (state.filterTab == NotesFilterTab.pinned) {
      state = state.copyWith(
        items: const [],
        page: 0,
        total: 0,
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        clearError: true,
        loadMoreError: false,
      );
      return true;
    }

    try {
      final keyword = state.keyword.trim();
      final response = await ref.read(notesServiceProvider).listNotes(
            page: page,
            size: AppConstants.notesPageSize,
            keyword: keyword.isEmpty ? null : keyword,
          );
      final data = response.data;
      if (response.isSuccess && data != null) {
        state = state.copyWith(
          items: replace ? data.items : [...state.items, ...data.items],
          page: data.page,
          total: data.total,
          isInitialLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          clearError: true,
          loadMoreError: false,
        );
        return true;
      }
      _handleFetchFailure(
        message: _messageOrFallback(response.message),
        replace: replace,
        isRefresh: isRefresh,
      );
      return false;
    } on DioException catch (e) {
      _handleFetchFailure(
        message: _dioErrorMessage(e),
        replace: replace,
        isRefresh: isRefresh,
      );
      return false;
    } catch (_) {
      _handleFetchFailure(
        message: UiStrings.notesLoadFailed,
        replace: replace,
        isRefresh: isRefresh,
      );
      return false;
    }
  }

  void _handleFetchFailure({
    required String message,
    required bool replace,
    required bool isRefresh,
  }) {
    if (!replace) {
      state = state.copyWith(isLoadingMore: false, loadMoreError: true);
      return;
    }
    if (isRefresh) {
      state = state.copyWith(isRefreshing: false);
      return;
    }
    state = state.copyWith(
      isInitialLoading: false,
      isRefreshing: false,
      errorMessage: message,
    );
  }

  String _dioErrorMessage(DioException e) {
    final err = e.error;
    if (err is ApiException && err.message.isNotEmpty) {
      return err.message;
    }
    return UiStrings.notesLoadFailed;
  }

  String _messageOrFallback(String message) {
    return message.isNotEmpty ? message : UiStrings.notesLoadFailed;
  }
}

final notesListProvider =
    NotifierProvider<NotesListNotifier, NotesListState>(NotesListNotifier.new);
