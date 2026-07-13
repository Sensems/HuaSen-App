import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_strings.dart';
import '../../core/network/shared_preferences_token_storage.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/auth_dtos.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  final ValueNotifier<int> routerRefresh = ValueNotifier<int>(0);

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d).{8,}$',
  );
  static final RegExp _codePattern = RegExp(r'^\d{6}$');

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
      state = AuthState(status: state.status, errorMessage: validationMessage);
      return;
    }

    state = AuthState(status: state.status, isSubmitting: true);

    try {
      final response = await ref
          .read(authServiceProvider)
          .emailLogin(email: trimmedEmail, password: password);
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

  /// Returns `true` only when the API accepts the send-code request.
  Future<bool> sendCode(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      state = AuthState(
        status: state.status,
        errorMessage: UiStrings.loginEmailRequired,
      );
      return false;
    }
    if (!_emailPattern.hasMatch(trimmedEmail)) {
      state = AuthState(
        status: state.status,
        errorMessage: UiStrings.loginEmailInvalid,
      );
      return false;
    }

    state = AuthState(status: state.status, isSendingCode: true);

    try {
      final response = await ref.read(authServiceProvider).sendEmailCode(
            email: trimmedEmail,
            purpose: EmailCodePurpose.register,
          );
      if (response.isSuccess) {
        state = AuthState(status: state.status);
        return true;
      }
      state = AuthState(
        status: state.status,
        isSendingCode: true,
        errorMessage: response.message,
      );
      return false;
    } on DioException {
      state = AuthState(
        status: state.status,
        isSendingCode: true,
        errorMessage: UiStrings.registerNetworkError,
      );
      return false;
    } finally {
      if (state.isSendingCode) {
        state = AuthState(
          status: state.status,
          errorMessage: state.errorMessage,
        );
      }
    }
  }

  /// Returns `true` on successful register. Does **not** persist tokens
  /// or set [AuthStatus.authenticated].
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String code,
    required bool agreedToTerms,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedCode = code.trim();
    final validationMessage = _validateRegister(
      email: trimmedEmail,
      password: password,
      confirmPassword: confirmPassword,
      code: trimmedCode,
      agreedToTerms: agreedToTerms,
    );
    if (validationMessage != null) {
      state = AuthState(status: state.status, errorMessage: validationMessage);
      return false;
    }

    state = AuthState(status: state.status, isSubmitting: true);

    try {
      final response = await ref
          .read(authServiceProvider)
          .emailRegister(
            email: trimmedEmail,
            password: password,
            code: trimmedCode,
          );
      if (response.isSuccess) {
        state = AuthState(status: state.status);
        return true;
      }
      state = AuthState(
        status: state.status,
        isSubmitting: true,
        errorMessage: response.message,
      );
      return false;
    } on DioException {
      state = AuthState(
        status: state.status,
        isSubmitting: true,
        errorMessage: UiStrings.registerNetworkError,
      );
      return false;
    } finally {
      if (state.isSubmitting) {
        state = AuthState(
          status: state.status,
          errorMessage: state.errorMessage,
        );
      }
    }
  }

  /// Dismisses a prior form error without changing the active auth request.
  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    state = AuthState(
      status: state.status,
      isSubmitting: state.isSubmitting,
      isSendingCode: state.isSendingCode,
    );
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

  String? _validateRegister({
    required String email,
    required String password,
    required String confirmPassword,
    required String code,
    required bool agreedToTerms,
  }) {
    if (email.isEmpty) {
      return UiStrings.loginEmailRequired;
    }
    if (!_emailPattern.hasMatch(email)) {
      return UiStrings.loginEmailInvalid;
    }
    if (code.isEmpty) {
      return UiStrings.registerCodeRequired;
    }
    if (!_codePattern.hasMatch(code)) {
      return UiStrings.registerCodeInvalid;
    }
    if (!_passwordPattern.hasMatch(password)) {
      return UiStrings.registerPasswordWeak;
    }
    if (password != confirmPassword) {
      return UiStrings.registerPasswordMismatch;
    }
    if (!agreedToTerms) {
      return UiStrings.registerTermsRequired;
    }
    return null;
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

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

  final isExpired =
      expiresAt != null && expiresAt <= DateTime.now().millisecondsSinceEpoch;
  final canRefresh = refreshToken != null && refreshToken.isNotEmpty;
  if (isExpired && !canRefresh) {
    return AuthStatus.unauthenticated;
  }

  return AuthStatus.authenticated;
}
