import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../features/wechat/drafts_count_provider.dart';

/// App shell with bottom tabs: notes / drafts / settings.
///
/// Clipboard stays a deep-link-only route and is not shown here.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith(AppConstants.routeSettings)) return 2;
    if (location.startsWith(AppConstants.routeDrafts)) return 1;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go(AppConstants.routeHome);
      case 1:
        context.go(AppConstants.routeDrafts);
      case 2:
        context.go(AppConstants.routeSettings);
    }
  }

  Widget _draftsIcon(IconData iconData, AsyncValue<int> countAsync) {
    final count = countAsync.asData?.value;
    if (count == null || count <= 0) {
      return Icon(iconData);
    }
    return Badge.count(
      count: count,
      child: Icon(iconData),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexForLocation(location);
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final draftsCount = ref.watch(draftsCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => _onDestinationSelected(context, i),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.note_outlined),
                  selectedIcon: Icon(Icons.note),
                  label: UiStrings.navNotes,
                ),
                NavigationDestination(
                  icon: _draftsIcon(Icons.drafts_outlined, draftsCount),
                  selectedIcon: _draftsIcon(Icons.drafts, draftsCount),
                  label: UiStrings.navDrafts,
                ),
                const NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: UiStrings.navSettings,
                ),
              ],
            ),
    );
  }
}
