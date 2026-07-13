import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../components/custom_bottom_nav.dart';

/// App shell with bottom tabs: notes / drafts / settings.
///
/// Clipboard stays a deep-link-only route and is not shown here.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith(AppConstants.routeSettings)) return 2;
    if (location.startsWith(AppConstants.routeDrafts)) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexForLocation(location);
    final wide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      body: child,
      bottomNavigationBar: wide
          ? null
          : CustomBottomNav(
              currentIndex: index,
              items: const [
                CustomNavItem(
                  icon: Icons.note_outlined,
                  activeIcon: Icons.note,
                  label: UiStrings.navNotes,
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
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go(AppConstants.routeHome);
                  case 1:
                    context.go(AppConstants.routeDrafts);
                  case 2:
                    context.go(AppConstants.routeSettings);
                }
              },
            ),
    );
  }
}
