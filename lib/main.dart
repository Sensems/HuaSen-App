import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/providers/core_providers.dart';
import 'features/auth/auth_notifier.dart';

/// Entry point for sebhua_notes.
///
/// Wraps the root [SebhuaNotesApp] in a [ProviderScope] so that every
/// Riverpod provider in the widget tree has an owner container.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final initialAuthStatus = initialAuthStatusFromStoredTokens(
    accessToken: prefs.getString(AppConstants.keyAccessToken),
    refreshToken: prefs.getString(AppConstants.keyRefreshToken),
    expiresAt: prefs.getInt(AppConstants.keyTokenExpiresAt),
  );

  final notificationService = LocalNotificationService();
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        initialAuthStatusProvider.overrideWithValue(initialAuthStatus),
        localNotificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const SebhuaNotesApp(),
    ),
  );
}