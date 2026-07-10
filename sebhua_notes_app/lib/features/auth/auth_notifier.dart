import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/shared_preferences_token_storage.dart';
import '../../core/providers/core_providers.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  final ValueNotifier<int> routerRefresh = ValueNotifier<int>(0);

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  int _bootstrapGeneration = 0;
  bool _isDisposed = false;

  @override
  AuthState build() {
    _isDisposed = false;
    final tokenRefresher = ref.watch(tokenRefresherProvider);
    final initialStatus = ref.watch(initialAuthStatusProvider);
    final bootstrapGeneration = ++_bootstrapGeneration;

    void handleSessionExpired() {
      state = const AuthState(status: AuthStatus.unauthenticated);
      routerRefresh.value++;
    }

    tokenRefresher.onSessionExpired = handleSessionExpired;
    ref.onDispose(() {
      _isDisposed = true;
      tokenRefresher.cancel();
      if (identical(tokenRefresher.onSessionExpired, handleSessionExpired)) {
        tokenRefresher.onSessionExpired = null;
      }
      routerRefresh.dispose();
    });

    scheduleMicrotask(() {
      unawaited(_bootstrap(bootstrapGeneration));
    });
    if (initialStatus == AuthStatus.authenticated) {
      tokenRefresher.scheduleProactiveRefresh();
    }

    return AuthState(status: initialStatus);
  }

  Future<void> login(String email, String password) async {
    final trimmedEmail = email.trim();
    final validationMessage = _validateLogin(trimmedEmail, password);

    if (validationMessage != null) {
      state = AuthState(
        status: state.status,
        errorMessage: validationMessage,
      );
      return;
    }

    state = AuthState(status: state.status, isSubmitting: true);

    try {
      final response = await ref.read(authServiceProvider).emailLogin(
            email: trimmedEmail,
            password: password,
          );
      final tokenResponse = response.data;

      if (response.isSuccess && tokenResponse != null) {
        final tokenStorage = ref.read(tokenStorageProvider);
        await tokenStorage.setToken(tokenResponse.accessToken);
        await tokenStorage.setRefreshToken(tokenResponse.refreshToken);
        await tokenStorage.setExpiresAt(
          SharedPreferencesTokenStorage.expiresAtFromExpiresIn(
            tokenResponse.expiresIn,
          ),
        );
        ref.read(tokenRefresherProvider).scheduleProactiveRefresh();
        state = const AuthState(status: AuthStatus.authenticated);
        routerRefresh.value++;
      } else {
        state = AuthState(
          status: state.status,
          isSubmitting: true,
          errorMessage: response.message,
        );
      }
    } on DioException {
      state = AuthState(
        status: state.status,
        isSubmitting: true,
        errorMessage: UiStrings.loginNetworkError,
      );
    } finally {
      if (state.isSubmitting) {
        state = AuthState(
          status: state.status,
          errorMessage: state.errorMessage,
        );
      }
    }
  }

  Future<void> forceLogout() async {
    ref.read(tokenRefresherProvider).cancel();
    await ref.read(tokenStorageProvider).clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
    routerRefresh.value++;
  }

  Future<void> _bootstrap(int generation) async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final accessToken = await tokenStorage.getToken();
    final refreshToken = await tokenStorage.getRefreshToken();
    final expiresAt = await tokenStorage.getExpiresAt();

    if (_isDisposed || generation != _bootstrapGeneration) {
      return;
    }

    final status = initialAuthStatusFromStoredTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
    final initialStatus = ref.read(initialAuthStatusProvider);

    if (status == AuthStatus.authenticated &&
        initialStatus != AuthStatus.authenticated) {
      ref.read(tokenRefresherProvider).scheduleProactiveRefresh();
    }

    state = AuthState(status: status);
    routerRefresh.value++;
  }

  String? _validateLogin(String email, String password) {
    if (email.isEmpty) {
      return UiStrings.loginEmailRequired;
    }
    if (!_emailPattern.hasMatch(email)) {
      return UiStrings.loginEmailInvalid;
    }
    if (password.trim().isEmpty) {
      return UiStrings.loginPasswordRequired;
    }
    return null;
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final initialAuthStatusProvider = Provider<AuthStatus>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return initialAuthStatusFromStoredTokens(
    accessToken: prefs.getString(AppConstants.keyAccessToken),
    refreshToken: prefs.getString(AppConstants.keyRefreshToken),
    expiresAt: prefs.getInt(AppConstants.keyTokenExpiresAt),
  );
});

AuthStatus initialAuthStatusFromStoredTokens({
  required String? accessToken,
  required String? refreshToken,
  required int? expiresAt,
}) {
  if (accessToken == null || accessToken.isEmpty) {
    return AuthStatus.unauthenticated;
  }

  final isExpired = expiresAt != null &&
      expiresAt <= DateTime.now().millisecondsSinceEpoch;
  final canRefresh = refreshToken != null && refreshToken.isNotEmpty;
  if (isExpired && !canRefresh) {
    return AuthStatus.unauthenticated;
  }

  return AuthStatus.authenticated;
}
