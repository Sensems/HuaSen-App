import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import 'notes_list_state.dart';

class NotesListNotifier extends Notifier<NotesListState> {
  /// Bumped on every fetch so stale responses cannot overwrite newer state.
  int _fetchGeneration = 0;

  @override
  NotesListState build() => const NotesListState();

  /// Loads page 1. Call from the screen on first frame (not from [build]).
  Future<void> loadInitial() async {
    if (state.isInitialLoading) return;
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      items: const [],
      page: 0,
      total: 0,
      isInitialLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      loadMoreError: false,
    );
    await _fetchPage(page: 1, replace: true, generation: generation);
  }

  /// Pull-to-refresh: page 1 replace. Returns `false` on failure (list kept).
  Future<bool> refresh() async {
    if (state.isRefreshing || state.isInitialLoading) return true;
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      isRefreshing: true,
      isLoadingMore: false,
      loadMoreError: false,
    );
    return _fetchPage(
      page: 1,
      replace: true,
      isRefresh: true,
      generation: generation,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.isInitialLoading ||
        state.isRefreshing ||
        !state.hasMore) {
      return;
    }
    final generation = ++_fetchGeneration;
    state = state.copyWith(isLoadingMore: true, loadMoreError: false);
    await _fetchPage(page: state.page + 1, replace: false, generation: generation);
  }

  /// Search page 1 replace. Returns `false` on failure (empty list + error).
  Future<bool> search(String keyword) async {
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      keyword: keyword.trim(),
      items: const [],
      page: 0,
      total: 0,
      isInitialLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      loadMoreError: false,
    );
    return _fetchPage(page: 1, replace: true, generation: generation);
  }

  /// Clears keyword and reloads page 1. Returns `false` on failure.
  Future<bool> clearSearch() async {
    if (state.keyword.isEmpty) return true;
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      keyword: '',
      items: const [],
      page: 0,
      total: 0,
      isInitialLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      loadMoreError: false,
    );
    return _fetchPage(page: 1, replace: true, generation: generation);
  }

  /// Switch filter tab. Returns `false` on failure (empty list + error).
  Future<bool> setFilter(NotesFilterTab tab) async {
    if (state.filterTab == tab) return true;
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      filterTab: tab,
      items: const [],
      page: 0,
      total: 0,
      isInitialLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      clearError: true,
      loadMoreError: false,
    );
    return _fetchPage(page: 1, replace: true, generation: generation);
  }

  Future<void> retry() => loadInitial();

  Future<bool> _fetchPage({
    required int page,
    required bool replace,
    required int generation,
    bool isRefresh = false,
  }) async {
    if (state.filterTab == NotesFilterTab.pinned) {
      if (generation != _fetchGeneration) return false;
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
      if (generation != _fetchGeneration) return false;

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
      if (generation != _fetchGeneration) return false;
      _handleFetchFailure(
        message: _dioErrorMessage(e),
        replace: replace,
        isRefresh: isRefresh,
      );
      return false;
    } catch (_) {
      if (generation != _fetchGeneration) return false;
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
      // Keep existing items; caller toasts.
      state = state.copyWith(isRefreshing: false);
      return;
    }
    // Replace fetches clear items up front — surface error for empty-state UI.
    state = state.copyWith(
      items: const [],
      page: 0,
      total: 0,
      isInitialLoading: false,
      isRefreshing: false,
      isLoadingMore: false,
      errorMessage: message,
      loadMoreError: false,
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
