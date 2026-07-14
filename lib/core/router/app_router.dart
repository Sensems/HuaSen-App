import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_notifier.dart';
import '../../features/auth/auth_state.dart';
import '../../features/auth/legal_placeholder_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/clipboard/clipboard_history_screen.dart';
import '../../features/notes/note_editor_screen.dart';
import '../../features/notes/notes_list_screen.dart';
import '../../features/settings/account_edit_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/wechat/drafts_screen.dart';
import '../../ui/shell/main_shell.dart';
import '../constants/app_constants.dart';
import '../constants/ui_strings.dart';

/// Configures the app's [GoRouter].
///
/// Authenticated main tabs live under a [ShellRoute] ([MainShell]).
/// Auth / legal routes, note editor, and clipboard stay outside the shell.
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: AppConstants.routeHome,
    refreshListenable: authNotifier.routerRefresh,
    redirect: (context, state) {
      final status = ref.read(authNotifierProvider).status;
      final location = state.matchedLocation;
      final isPublicRoute = location == AppConstants.routeLogin ||
          location == AppConstants.routeRegister ||
          location == AppConstants.routeResetPassword ||
          location == AppConstants.routeLegalTerms ||
          location == AppConstants.routeLegalPrivacy;

      if (status == AuthStatus.unknown) {
        return isPublicRoute ? null : AppConstants.routeLogin;
      }

      if (status == AuthStatus.unauthenticated && !isPublicRoute) {
        return AppConstants.routeLogin;
      }
      if (status == AuthStatus.authenticated && isPublicRoute) {
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
        path: AppConstants.routeRegister,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeResetPassword,
        name: 'reset-password',
        builder: (context, state) {
          final email = state.extra is String ? state.extra as String : '';
          return ResetPasswordScreen(initialEmail: email);
        },
      ),
      GoRoute(
        path: AppConstants.routeLegalTerms,
        name: 'legal-terms',
        builder: (context, state) => const LegalPlaceholderScreen(
          title: UiStrings.legalTermsTitle,
        ),
      ),
      GoRoute(
        path: AppConstants.routeLegalPrivacy,
        name: 'legal-privacy',
        builder: (context, state) => const LegalPlaceholderScreen(
          title: UiStrings.legalPrivacyTitle,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppConstants.routeHome,
            name: 'home',
            builder: (context, state) => const NotesListScreen(),
          ),
          GoRoute(
            path: AppConstants.routeDrafts,
            name: 'drafts',
            builder: (context, state) => const DraftsScreen(),
          ),
          GoRoute(
            path: AppConstants.routeSettings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.routeNote,
        name: 'note',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? AppConstants.newNoteId;
          return NoteEditorScreen(noteId: id);
        },
      ),
      GoRoute(
        path: AppConstants.routeSettingsAccount,
        name: 'settings-account',
        builder: (context, state) => const AccountEditScreen(),
      ),
      GoRoute(
        path: AppConstants.routeClipboard,
        name: 'clipboard',
        builder: (context, state) => const ClipboardHistoryScreen(),
      ),
    ],
    errorBuilder: (context, state) => _PlaceholderScreen(
      title: 'Not Found',
      subtitle: 'No route for ${state.uri}',
    ),
  );
});

/// Fallback for unmatched routes.
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
