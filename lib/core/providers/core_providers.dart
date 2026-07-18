import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/notes_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/user_service.dart';
import '../network/dio_client.dart';
import '../network/shared_preferences_token_storage.dart';
import '../network/token_refresher.dart';
import '../network/token_storage.dart';
import '../notifications/local_notification_service.dart';

/// Synchronous SharedPreferences dependency.
///
/// Override this in `main.dart` after obtaining an instance, and in tests.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main/tests');
});

/// Stores access, refresh, and expiry token state.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SharedPreferencesTokenStorage(ref.watch(sharedPreferencesProvider));
});

/// Dio client used only for token refresh.
final refreshDioProvider = Provider<Dio>((ref) => DioClient.createRefreshDio());

/// Coordinates refresh-token calls and proactive refresh scheduling.
final tokenRefresherProvider = Provider<TokenRefresher>((ref) {
  final refresher = TokenRefresher(
    tokenStorage: ref.watch(tokenStorageProvider),
    refreshDio: ref.watch(refreshDioProvider),
  );
  ref.onDispose(refresher.cancel);
  return refresher;
});

/// Main API Dio client.
final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(
    tokenStorage: ref.watch(tokenStorageProvider),
    tokenRefresher: ref.watch(tokenRefresherProvider),
  );
});

/// Authentication API service.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider));
});

/// Notes API service.
final notesServiceProvider = Provider<NotesService>((ref) {
  return NotesService(ref.watch(dioProvider));
});

/// User profile / binding API service.
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(dioProvider));
});

/// Object-storage upload / delete API service.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(dioProvider));
});

/// Local system notifications (draft updates; Web no-op).
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});
