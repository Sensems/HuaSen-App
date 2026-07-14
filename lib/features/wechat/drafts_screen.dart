import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/ui_strings.dart';
import 'drafts_list_notifier.dart';
import 'drafts_list_state.dart';
import 'widgets/draft_list_card.dart';
import 'widgets/drafts_filter_chips.dart';

class DraftsScreen extends ConsumerStatefulWidget {
  const DraftsScreen({super.key});

  @override
  ConsumerState<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends ConsumerState<DraftsScreen> {
  final _scrollController = ScrollController();
  var _didRequestInitial = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadInitial());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _maybeLoadInitial() {
    if (!mounted || _didRequestInitial) return;
    final state = ref.read(draftsListProvider);
    if (state.page == 0 &&
        !state.isInitialLoading &&
        state.items.isEmpty &&
        state.errorMessage == null) {
      _didRequestInitial = true;
      ref.read(draftsListProvider.notifier).loadInitial();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(draftsListProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    final ok = await ref.read(draftsListProvider.notifier).refresh();
    if (!ok && mounted) {
      $message.error(message: UiStrings.draftsRefreshFailed);
    }
  }

  Future<void> _onDelete(String id) async {
    final errorMessage =
        await ref.read(draftsListProvider.notifier).deleteDraft(id);
    if (errorMessage != null && mounted) {
      $message.error(message: errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final state = ref.watch(draftsListProvider);
    final notifier = ref.read(draftsListProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                UiStrings.draftsTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: DraftsFilterChips(
                value: state.filter,
                onChanged: notifier.setFilter,
              ),
            ),
            Expanded(child: _buildListBody(state, notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildListBody(DraftsListState state, DraftsListNotifier notifier) {
    if (state.isInitialLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return _EmptyMessage(
        title: state.errorMessage!,
        actionLabel: UiStrings.draftsRetry,
        onAction: notifier.retry,
      );
    }

    if (state.items.isEmpty) {
      return const _EmptyMessage(
        title: UiStrings.noDrafts,
        subtitle: UiStrings.noDraftsHint,
      );
    }

    final itemCount = state.items.length + 1;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: itemCount,
        separatorBuilder: (_, index) {
          if (index >= state.items.length - 1) {
            return const SizedBox.shrink();
          }
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return _ListFooter(
              isLoadingMore: state.isLoadingMore,
              loadMoreError: state.loadMoreError,
              hasMore: state.hasMore,
              onRetryLoadMore: notifier.loadMore,
            );
          }
          final note = state.items[index];
          return DraftListCard(
            note: note,
            onOpen: () => context.push('/note/${note.id}'),
            onDelete: () => _onDelete(note.id),
          );
        },
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({
    required this.isLoadingMore,
    required this.loadMoreError,
    required this.hasMore,
    required this.onRetryLoadMore,
  });

  final bool isLoadingMore;
  final bool loadMoreError;
  final bool hasMore;
  final VoidCallback onRetryLoadMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (loadMoreError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: TextButton(
            onPressed: onRetryLoadMore,
            child: const Text(UiStrings.draftsLoadMoreFailed),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            UiStrings.draftsNoMore,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 8);
  }
}
