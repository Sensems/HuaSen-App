import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tolyui_message/tolyui_message.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
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
    return TolyMessage(
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
    );
  }
}
