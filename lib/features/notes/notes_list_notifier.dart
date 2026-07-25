import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/note_dtos.dart';
import 'notes_list_query.dart';
import 'notes_list_state.dart';

class NotesListNotifier extends Notifier<NotesListState> {
  NotesListNotifier(this.tab);

  final NotesFilterTab tab;

  /// Bumped on every fetch so stale responses cannot overwrite newer state.
  int _fetchGeneration = 0;

  @override
  NotesListState build() {
    ref
      ..watch(notesListQueryProvider)
      ..listen(notesListQueryProvider, (previous, next) {
        if (previous == null || previous == next) return;
        if (stateOrNull == null) return;
        unawaited(_reloadOnQueryChange());
      });

    return stateOrNull ?? const NotesListState();
  }

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

  Future<void> retry() => loadInitial();

  Future<void> _reloadOnQueryChange() async {
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

  Future<bool> _fetchPage({
    required int page,
    required bool replace,
    required int generation,
    bool isRefresh = false,
  }) async {
    try {
      final query = ref.read(notesListQueryProvider);
      final keyword = query.keyword.trim();
      final tags = query.tagIds;
      final response = await ref.read(notesServiceProvider).listNotes(
            page: page,
            size: AppConstants.notesPageSize,
            type: 'PUBLISHED',
            keyword: keyword.isEmpty ? null : keyword,
            category: query.categoryId,
            tags: tags.isEmpty ? null : tags,
            view: switch (tab) {
              NotesFilterTab.pinned => NotesListView.pinned,
              NotesFilterTab.recent => NotesListView.recent,
              NotesFilterTab.all => null,
            },
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
    NotifierProvider.family<NotesListNotifier, NotesListState, NotesFilterTab>(
  NotesListNotifier.new,
);

/// Refreshes only tab list instances that have been created (visited).
Future<void> refreshExistingNotesLists(WidgetRef ref) async {
  for (final tab in NotesFilterTab.values) {
    if (ref.exists(notesListProvider(tab))) {
      await ref.read(notesListProvider(tab).notifier).refresh();
    }
  }
}
