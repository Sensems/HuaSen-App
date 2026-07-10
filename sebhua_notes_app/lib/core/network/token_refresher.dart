import 'dart:async';

import 'package:dio/dio.dart';

import '../../data/models/api_response.dart';
import '../../data/models/auth_dtos.dart' show TokenResponseDto;
import '../constants/app_constants.dart';
import 'token_storage.dart';

/// Refreshes access tokens and schedules proactive refresh before expiry.
class TokenRefresher {
  TokenRefresher({
    required this.tokenStorage,
    required this.refreshDio,
  });

  /// Storage used for access, refresh, and expiry token state.
  final TokenStorage tokenStorage;

  /// Dio client used for refresh calls.
  final Dio refreshDio;

  Future<bool>? _inFlight;
  Timer? _timer;
  int _scheduleGeneration = 0;
  bool _sessionExpiredNotified = false;

  /// Late-bound session expiry hook, intentionally independent of Riverpod.
  void Function()? onSessionExpired;

  /// Refreshes the access token, coalescing concurrent callers.
  Future<bool> refresh() {
    final inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }

    late final Future<bool> refreshFuture;
    var shouldScheduleNextRefresh = false;
    refreshFuture = _refresh().then((success) {
      shouldScheduleNextRefresh = success;
      return success;
    }).whenComplete(() {
      if (identical(_inFlight, refreshFuture)) {
        _inFlight = null;
      }
      if (shouldScheduleNextRefresh) {
        scheduleProactiveRefresh();
      }
    });
    _inFlight = refreshFuture;
    return refreshFuture;
  }

  /// Schedules a refresh at `expiresAt - tokenRefreshSkew`.
  void scheduleProactiveRefresh() {
    _timer?.cancel();
    _timer = null;

    final generation = ++_scheduleGeneration;
    unawaited(_scheduleProactiveRefresh(generation));
  }

  /// Cancels any pending proactive refresh.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _scheduleGeneration += 1;
  }

  /// Clears tokens, cancels refresh work, and notifies listeners once.
  Future<void> expireSession() async {
    cancel();
    await tokenStorage.clearToken();
    if (_sessionExpiredNotified) {
      return;
    }
    _sessionExpiredNotified = true;
    onSessionExpired?.call();
  }

  Future<bool> _refresh() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await expireSession();
      return false;
    }

    try {
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => TokenResponseDto.fromJson(json as Map<String, dynamic>),
      );
      final tokenResponse = apiResponse.data;

      if (!apiResponse.isSuccess || tokenResponse == null) {
        await expireSession();
        return false;
      }

      await tokenStorage.setToken(tokenResponse.accessToken);
      await tokenStorage.setRefreshToken(tokenResponse.refreshToken);
      await tokenStorage.setExpiresAt(
        DateTime.now().millisecondsSinceEpoch + tokenResponse.expiresIn * 1000,
      );
      _sessionExpiredNotified = false;
      return true;
    } on Object {
      await expireSession();
      return false;
    }
  }

  Future<void> _scheduleProactiveRefresh(int generation) async {
    final expiresAt = await tokenStorage.getExpiresAt();
    if (generation != _scheduleGeneration || expiresAt == null) {
      return;
    }

    final refreshAt = expiresAt -
        AppConstants.tokenRefreshSkewSeconds * Duration.millisecondsPerSecond;
    final delayMs = refreshAt - DateTime.now().millisecondsSinceEpoch;

    if (delayMs <= 0) {
      _refreshAndReschedule();
      return;
    }

    _timer = Timer(Duration(milliseconds: delayMs), () {
      _timer = null;
      _refreshAndReschedule();
    });
  }

  void _refreshAndReschedule() {
    unawaited(refresh());
  }
}
