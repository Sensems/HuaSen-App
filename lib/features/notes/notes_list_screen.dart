import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tolyui_message/tolyui_message.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import 'notes_list_notifier.dart';
import 'notes_list_query.dart';
import 'notes_list_state.dart';
import 'widgets/expandable_search_button.dart';
import 'widgets/note_list_card.dart';
import 'widgets/notes_filter_sheet.dart';
import 'widgets/notes_filter_tabs.dart';

/// Notes list with sticky brand header, filter tabs, and paginated API data.
///
/// Bottom navigation is owned by the shell (Task 5) — this screen has none.
class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  static const _tabOrder = <NotesFilterTab>[
    NotesFilterTab.all,
    NotesFilterTab.pinned,
    NotesFilterTab.recent,
  ];

  final _searchController = TextEditingController();
  late final PageController _pageController;
  var _activeTab = NotesFilterTab.all;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  int _tabIndex(NotesFilterTab tab) => _tabOrder.indexOf(tab);

  void _onTabChanged(NotesFilterTab tab) {
    setState(() {
      _activeTab = tab;
    });
    _pageController.animateToPage(
      _tabIndex(tab),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _activeTab = _tabOrder[index];
    });
  }

  void _onSearchSubmit() {
    ref
        .read(notesListQueryProvider.notifier)
        .setKeyword(_searchController.text);
  }

  void _onSearchCollapsedClear() {
    ref.read(notesListQueryProvider.notifier).clearKeyword();
  }

  Future<void> _onCategoryTagFilterTap() async {
    final query = ref.read(notesListQueryProvider);
    final result = await showNotesFilterSheet(
      context,
      initialCategoryId: query.categoryId,
      initialTagIds: query.tagIds,
    );
    if (!mounted || result == null) return;
    ref.read(notesListQueryProvider.notifier).setCategoryTagFilter(
          categoryId: result.categoryId,
          tagIds: result.tagIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final query = ref.watch(notesListQueryProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              searchController: _searchController,
              onSearchSubmit: _onSearchSubmit,
              onSearchCollapsedClear: _onSearchCollapsedClear,
              onAdd: () => context.push('/note/${AppConstants.newNoteId}'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
              child: NotesFilterTabs(
                value: _activeTab,
                onChanged: _onTabChanged,
                onFilterTap: _onCategoryTagFilterTap,
                hasActiveFilter: query.hasCategoryTagFilter,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tabOrder.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) =>
                    _NotesListTabPage(tab: _tabOrder[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesListTabPage extends ConsumerStatefulWidget {
  const _NotesListTabPage({required this.tab});

  final NotesFilterTab tab;

  @override
  ConsumerState<_NotesListTabPage> createState() => _NotesListTabPageState();
}

class _NotesListTabPageState extends ConsumerState<_NotesListTabPage>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  var _didRequestInitial = false;

  @override
  bool get wantKeepAlive => true;

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
    final state = ref.read(notesListProvider(widget.tab));
    if (state.page == 0 &&
        !state.isInitialLoading &&
        state.items.isEmpty &&
        state.errorMessage == null) {
      _didRequestInitial = true;
      ref.read(notesListProvider(widget.tab).notifier).loadInitial();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(notesListProvider(widget.tab).notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    final ok =
        await ref.read(notesListProvider(widget.tab).notifier).refresh();
    if (!ok && mounted) {
      $message.error(message: UiStrings.notesRefreshFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final query = ref.watch(notesListQueryProvider);
    final state = ref.watch(notesListProvider(widget.tab));
    final notifier = ref.read(notesListProvider(widget.tab).notifier);

    if (state.isInitialLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return _EmptyMessage(
        title: state.errorMessage!,
        actionLabel: UiStrings.notesRetry,
        onAction: notifier.retry,
      );
    }

    if (state.items.isEmpty) {
      final hasKeyword = query.keyword.trim().isNotEmpty;
      if (widget.tab == NotesFilterTab.pinned && !hasKeyword) {
        return const _EmptyMessage(
          title: UiStrings.notesPinnedEmpty,
          subtitle: UiStrings.notesPinnedEmptyHint,
        );
      }
      return _EmptyMessage(
        title: hasKeyword ? UiStrings.noSearchResults : UiStrings.noNotesFound,
        subtitle:
            hasKeyword ? UiStrings.noSearchResultsHint : UiStrings.noNotesHint,
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

          final item = state.items[index];
          final note = item.note;
          return NoteListCard(
            note: note,
            media: item.media,
            showPinChrome: note.pinnedAt != null,
            onTap: () => context.push('/note/${note.id}'),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.onSearchSubmit,
    required this.onSearchCollapsedClear,
    required this.onAdd,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchSubmit;
  final VoidCallback onSearchCollapsedClear;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        children: [
          Text(
            UiStrings.notesBrandTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontSize: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: ExpandableSearchButton(
                controller: searchController,
                onSubmit: onSearchSubmit,
                onCollapsedClear: onSearchCollapsedClear,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.add,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
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
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
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
            child: const Text(UiStrings.notesLoadMoreFailed),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            UiStrings.notesNoMore,
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
