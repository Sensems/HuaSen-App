import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tolyui_message/tolyui_message.dart';

import 'core/constants/app_constants.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'features/auth/auth_notifier.dart';
import 'features/auth/auth_state.dart';
import 'features/wechat/drafts_watch_coordinator.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/theme_provider.dart';

/// Root widget for sebhua_notes.
///
/// Wraps [MaterialApp.router] with a [GoRouter] provided by
/// [routerProvider] and applies the light/dark [ThemeData] from
/// [AppTheme] based on the current [ThemeMode] held in
/// [themeModeProvider].
class SebhuaNotesApp extends ConsumerWidget {
  const SebhuaNotesApp({super.key});

  static const List<LocalizationsDelegate<dynamic>> _messageLocalizations = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    // TolyMessage builds its own [Localizations] above [MaterialApp], so it
    // must receive the standard Flutter delegates (empty list crashes).
    return _DraftsWatchBootstrap(
      child: TolyMessage(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: _messageLocalizations,
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: _messageLocalizations,
          routerConfig: router,
        ),
      ),
    );
  }
}

/// Keeps [draftsWatchProvider] alive, requests notification permission once
/// when authenticated, and routes notification taps to the drafts tab.
class _DraftsWatchBootstrap extends ConsumerStatefulWidget {
  const _DraftsWatchBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_DraftsWatchBootstrap> createState() =>
      _DraftsWatchBootstrapState();
}

class _DraftsWatchBootstrapState extends ConsumerState<_DraftsWatchBootstrap> {
  bool _permissionRequested = false;
  bool _tapHandlerSet = false;
  bool _launchNavigationHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestPermissionIfAuthenticated(ref.read(authNotifierProvider));
      unawaited(_handleColdStartNotificationLaunch());
    });
  }

  Future<void> _handleColdStartNotificationLaunch() async {
    final payload =
        await ref.read(localNotificationServiceProvider).pendingLaunchPayload();
    if (!mounted) return;
    _goToDraftsIfPayload(payload);
  }

  bool _isDraftsPayload(String? payload) {
    return payload == AppConstants.routeDrafts || payload == 'drafts';
  }

  void _goToDraftsIfPayload(String? payload) {
    if (!_isDraftsPayload(payload) || _launchNavigationHandled) return;
    _launchNavigationHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(routerProvider).go(AppConstants.routeDrafts);
    });
  }

  void _requestPermissionIfAuthenticated(AuthState auth) {
    if (auth.status == AuthStatus.authenticated && !_permissionRequested) {
      _permissionRequested = true;
      unawaited(
        ref.read(localNotificationServiceProvider).requestPermission(),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tapHandlerSet) return;
    _tapHandlerSet = true;
    ref.read(localNotificationServiceProvider).setOnSelect(_goToDraftsIfPayload);
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..watch(draftsWatchProvider)
      ..listen(authNotifierProvider, (prev, next) {
        _requestPermissionIfAuthenticated(next);
      });

    return widget.child;
  }
}
