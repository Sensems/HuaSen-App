import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import 'drafts_count_provider.dart';
import 'drafts_list_state.dart';

class DraftsListNotifier extends Notifier<DraftsListState> {
  int _fetchGeneration = 0;

  @override
  DraftsListState build() => const DraftsListState();

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

  Future<bool> refresh() async {
    if (state.isRefreshing || state.isInitialLoading) return true;
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      isRefreshing: true,
      isLoadingMore: false,
      loadMoreError: false,
    );
    final ok = await _fetchPage(
      page: 1,
      replace: true,
      isRefresh: true,
      generation: generation,
    );
    if (ok) {
      await ref.read(draftsCountProvider.notifier).refresh();
    }
    return ok;
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
    await _fetchPage(
      page: state.page + 1,
      replace: false,
      generation: generation,
    );
  }

  Future<bool> setFilter(DraftsFilter filter) async {
    if (state.filter == filter) return true;
    final generation = ++_fetchGeneration;
    state = state.copyWith(
      filter: filter,
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

  /// Returns `null` on success, or an error message to show in a toast.
  Future<String?> deleteDraft(String id) async {
    try {
      final response = await ref.read(notesServiceProvider).deleteNote(id);
      if (!response.isSuccess) {
        return _messageOrFallback(
          response.message,
          fallback: UiStrings.draftsDeleteFailed,
        );
      }
      state = state.copyWith(
        items: state.items.where((n) => n.id != id).toList(),
        total: state.total > 0 ? state.total - 1 : 0,
      );
      await ref.read(draftsCountProvider.notifier).refresh();
      return null;
    } on DioException catch (e) {
      return _dioErrorMessage(e, fallback: UiStrings.draftsDeleteFailed);
    } catch (_) {
      return UiStrings.draftsDeleteFailed;
    }
  }

  Future<bool> _fetchPage({
    required int page,
    required bool replace,
    required int generation,
    bool isRefresh = false,
  }) async {
    try {
      final response = await ref.read(notesServiceProvider).listNotes(
            page: page,
            size: AppConstants.notesPageSize,
            type: 'DRAFT',
            mediaType: state.filter.mediaType,
          );
      if (generation != _fetchGeneration) return true;

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
      if (generation != _fetchGeneration) return true;
      _handleFetchFailure(
        message: _dioErrorMessage(e),
        replace: replace,
        isRefresh: isRefresh,
      );
      return false;
    } catch (_) {
      if (generation != _fetchGeneration) return true;
      _handleFetchFailure(
        message: UiStrings.draftsLoadFailed,
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

  String _dioErrorMessage(
    DioException e, {
    String fallback = UiStrings.draftsLoadFailed,
  }) {
    final err = e.error;
    if (err is ApiException && err.message.isNotEmpty) {
      return err.message;
    }
    return fallback;
  }

  String _messageOrFallback(
    String message, {
    String fallback = UiStrings.draftsLoadFailed,
  }) {
    return message.isNotEmpty ? message : fallback;
  }
}

final draftsListProvider =
    NotifierProvider<DraftsListNotifier, DraftsListState>(
      DraftsListNotifier.new,
    );
