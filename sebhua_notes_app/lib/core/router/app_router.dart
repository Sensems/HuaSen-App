import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_notifier.dart';
import '../../features/auth/auth_state.dart';
import '../../features/auth/login_screen.dart';
import '../constants/app_constants.dart';

/// Configures the app's [GoRouter].
///
/// Routes are defined as top-level entries — no nested [ShellRoute]
/// is used yet because the shell (scaffold with bottom nav / rail)
/// will be added in a later task alongside the real screen widgets.
///
/// The builder callbacks return minimal placeholder [Scaffold]s so the
/// router compiles and navigates immediately.  Each placeholder will
/// be replaced by the real screen widget in a separate task.
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: AppConstants.routeHome,
    refreshListenable: authNotifier.routerRefresh,
    redirect: (context, state) {
      final status = ref.read(authNotifierProvider).status;
      final isLoginRoute = state.matchedLocation == AppConstants.routeLogin;
      if (status == AuthStatus.unknown) {
        return isLoginRoute ? null : AppConstants.routeLogin;
      }

      if (status == AuthStatus.unauthenticated && !isLoginRoute) {
        return AppConstants.routeLogin;
      }
      if (status == AuthStatus.authenticated && isLoginRoute) {
        return AppConstants.routeHome;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeHome,
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Notes',
          subtitle: 'Home / notes list — placeholder',
        ),
      ),
      GoRoute(
        path: AppConstants.routeNote,
        name: 'note',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? AppConstants.newNoteId;
          final isNew = id == AppConstants.newNoteId;
          return _PlaceholderScreen(
            title: isNew ? 'New Note' : 'Edit Note',
            subtitle: 'Note editor — placeholder\nid: $id',
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        name: 'settings',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Settings',
          subtitle: 'Settings — placeholder',
        ),
      ),
      GoRoute(
        path: AppConstants.routeClipboard,
        name: 'clipboard',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Clipboard',
          subtitle: 'Clipboard / scratch space — placeholder',
        ),
      ),
    ],
    errorBuilder: (context, state) => _PlaceholderScreen(
      title: 'Not Found',
      subtitle: 'No route for ${state.uri}',
    ),
  );
});

/// Minimal placeholder used by every route until the real screen
/// widgets are implemented in a separate task.
///
/// This is intentionally not a shared / reusable widget — it exists
/// only so the router has something to render.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
