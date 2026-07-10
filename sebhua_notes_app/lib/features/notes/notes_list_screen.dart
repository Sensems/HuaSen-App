import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/ui_strings.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_bottom_nav.dart';
import '../../ui/components/custom_card.dart';
import '../../ui/components/custom_input.dart';

/// Placeholder note data used until the data layer is implemented.
class _NoteItem {
  const _NoteItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.timestamp,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String preview;
  final String timestamp;
  final bool isPinned;
}

/// Screen showing a searchable list of notes.
///
/// Displays a search bar in the app bar, a floating action button to create
/// new notes, and a list of [CustomCard] widgets. On wide screens the list
/// switches to a two-column grid.
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _searchController = TextEditingController();

  /// Mock data — replaced by a provider/repository in a later task.
  final List<_NoteItem> _notes = const [
    _NoteItem(
      id: '1',
      title: 'Project Roadmap',
      preview:
          'Q1 milestones include finishing the UI components, setting up the database layer, and integrating clipboard monitoring.',
      timestamp: '2 hours ago',
      isPinned: true,
    ),
    _NoteItem(
      id: '2',
      title: 'Meeting Notes',
      preview:
          'Discussed the architecture for the sync engine. Decided on a queue-based approach with conflict resolution.',
      timestamp: 'Yesterday',
    ),
    _NoteItem(
      id: '3',
      title: 'Reading List',
      preview:
          'Effective Dart, Riverpod documentation, GoRouter best practices, and the Material 3 color system guide.',
      timestamp: '3 days ago',
    ),
    _NoteItem(
      id: '4',
      title: 'Ideas',
      preview:
          'Add a quick-capture widget. Voice-to-text for notes. Auto-tagging based on content analysis.',
      timestamp: '1 week ago',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isWide => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: UiStrings.navNotes,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: UiStrings.settings,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: CustomInput(
              controller: _searchController,
              hint: UiStrings.searchNotes,
              prefixIcon: Icons.search,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note/new'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _isWide
          ? null
          : CustomBottomNav(
              currentIndex: 0,
              items: const [
                CustomNavItem(
                  icon: Icons.note_outlined,
                  activeIcon: Icons.note,
                  label: UiStrings.navNotes,
                ),
                CustomNavItem(
                  icon: Icons.content_copy_outlined,
                  activeIcon: Icons.content_copy,
                  label: UiStrings.navClipboard,
                ),
                CustomNavItem(
                  icon: Icons.drafts_outlined,
                  activeIcon: Icons.drafts,
                  label: UiStrings.navDrafts,
                ),
                CustomNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: UiStrings.navSettings,
                ),
              ],
              onTap: _onNavTap,
            ),
    );
  }

  Widget _buildBody() {
    final filtered = _filterNotes();

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    if (_isWide) {
      return _buildWideGrid(filtered);
    }

    return _buildMobileList(filtered);
  }

  Widget _buildMobileList(List<_NoteItem> notes) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        return CustomCard(
          title: note.title,
          preview: note.preview,
          timestamp: note.timestamp,
          isPinned: note.isPinned,
          onTap: () => context.push('/note/${note.id}'),
        );
      },
    );
  }

  Widget _buildWideGrid(List<_NoteItem> notes) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return CustomCard(
          title: note.title,
          preview: note.preview,
          timestamp: note.timestamp,
          isPinned: note.isPinned,
          onTap: () => context.push('/note/${note.id}'),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            UiStrings.noNotesFound,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            UiStrings.noNotesHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  List<_NoteItem> _filterNotes() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _notes;
    return _notes
        .where(
          (n) =>
              n.title.toLowerCase().contains(query) ||
              n.preview.toLowerCase().contains(query),
        )
        .toList();
  }

  void _onNavTap(int index) {
    switch (index) {
      case 1:
        context.go('/clipboard');
      case 2:
        context.go('/drafts');
      case 3:
        context.go('/settings');
    }
  }
}