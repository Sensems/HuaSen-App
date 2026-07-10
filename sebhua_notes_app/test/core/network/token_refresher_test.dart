import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sebhua_notes/core/constants/app_constants.dart';
import 'package:sebhua_notes/core/network/token_refresher.dart';
import 'package:sebhua_notes/core/network/token_storage.dart';

void main() {
  late _MemoryTokenStorage storage;
  late _RefreshAdapter adapter;
  late Dio dio;

  setUp(() {
    storage = _MemoryTokenStorage();
    adapter = _RefreshAdapter();
    dio = Dio()..httpClientAdapter = adapter;
  });

  test('coalesces concurrent refresh calls into one HTTP request', () async {
    await storage.setRefreshToken('refresh-1');
    final responseCompleter = Completer<Map<String, Object?>>();
    final requestStarted = Completer<void>();
    adapter
      ..onFetch = requestStarted.complete
      ..nextResponse = () => responseCompleter.future;
    final refresher = TokenRefresher(tokenStorage: storage, refreshDio: dio);

    final first = refresher.refresh();
    final second = refresher.refresh();
    await requestStarted.future;

    expect(adapter.callCount, 1);
    responseCompleter.complete(_successBody());

    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(adapter.requestBodies, [
      {'refreshToken': 'refresh-1'},
    ]);
  });

  test('writes new tokens and expiry after successful refresh', () async {
    await storage.setRefreshToken('old-refresh');
    adapter.nextResponse = () async => _successBody(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
      expiresIn: 30,
    );
    final refresher = TokenRefresher(tokenStorage: storage, refreshDio: dio);

    final earliestExpiresAt = DateTime.now().millisecondsSinceEpoch + 30000;
    final refreshed = await refresher.refresh();
    final latestExpiresAt = DateTime.now().millisecondsSinceEpoch + 30000;

    expect(refreshed, isTrue);
    expect(await storage.getToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');
    expect(await storage.getExpiresAt(), inInclusiveRange(
      earliestExpiresAt,
      latestExpiresAt,
    ));
  });

  test('successful manual refresh schedules proactive refresh', () async {
    await storage.setRefreshToken('old-refresh');
    final secondRefreshStarted = Completer<void>();
    adapter.nextResponse = () async {
      if (adapter.callCount == 1) {
        return _successBody(
          refreshToken: 'refresh-again',
          expiresIn: AppConstants.tokenRefreshSkewSeconds - 1,
        );
      }
      if (!secondRefreshStarted.isCompleted) {
        secondRefreshStarted.complete();
      }
      return _successBody(expiresIn: AppConstants.tokenRefreshSkewSeconds + 2);
    };
    final refresher = TokenRefresher(tokenStorage: storage, refreshDio: dio);
    addTearDown(refresher.cancel);

    expect(await refresher.refresh(), isTrue);
    await Future.any<void>([
      secondRefreshStarted.future,
      Future<void>.delayed(const Duration(milliseconds: 50)),
    ]);

    expect(adapter.callCount, 2);
  });

  test('clears storage and expires the session once after refresh failure',
      () async {
    await storage.setToken('old-access');
    await storage.setRefreshToken('old-refresh');
    await storage.setExpiresAt(123);
    adapter.nextResponse = () async => <String, Object?>{
      'code': 401,
      'message': 'Unauthorized',
      'data': null,
    };
    final refresher = TokenRefresher(tokenStorage: storage, refreshDio: dio);
    var sessionExpiredCount = 0;
    refresher.onSessionExpired = () {
      sessionExpiredCount += 1;
    };

    final first = refresher.refresh();
    final second = refresher.refresh();

    expect(await first, isFalse);
    expect(await second, isFalse);
    expect(adapter.callCount, 1);
    expect(await storage.getToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
    expect(await storage.getExpiresAt(), isNull);
    expect(sessionExpiredCount, 1);
  });

  test('schedules future refresh without refreshing immediately', () async {
    await storage.setRefreshToken('refresh-1');
    await storage.setExpiresAt(
      DateTime.now().millisecondsSinceEpoch +
          (AppConstants.tokenRefreshSkewSeconds + 2) * 1000,
    );
    adapter.nextResponse = () async => _successBody();
    final refresher = TokenRefresher(tokenStorage: storage, refreshDio: dio);
    addTearDown(refresher.cancel);

    refresher.scheduleProactiveRefresh();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(adapter.callCount, 0);
  });

  test('refreshes promptly when expiry is within the proactive skew', () async {
    await storage.setRefreshToken('refresh-1');
    await storage.setExpiresAt(
      DateTime.now().millisecondsSinceEpoch +
          (AppConstants.tokenRefreshSkewSeconds - 1) * 1000,
    );
    final requestCompleter = Completer<void>();
    adapter.nextResponse = () async {
      requestCompleter.complete();
      return _successBody(expiresIn: AppConstants.tokenRefreshSkewSeconds + 2);
    };
    final refresher = TokenRefresher(tokenStorage: storage, refreshDio: dio);
    addTearDown(refresher.cancel);

    refresher.scheduleProactiveRefresh();
    await requestCompleter.future;

    expect(adapter.callCount, 1);
  });
}

Map<String, Object?> _successBody({
  String accessToken = 'access-2',
  String refreshToken = 'refresh-2',
  int expiresIn = 120,
}) =>
    <String, Object?>{
      'code': 200,
      'message': 'OK',
      'data': <String, Object?>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
      },
    };

class _RefreshAdapter implements HttpClientAdapter {
  int callCount = 0;
  final requestBodies = <Object?>[];
  void Function()? onFetch;
  Future<Map<String, Object?>> Function()? nextResponse;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount += 1;
    requestBodies.add(options.data);
    onFetch?.call();
    expect(options.path, '/auth/refresh');

    final response = await nextResponse!.call();
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _MemoryTokenStorage implements TokenStorage {
  String? _token;
  String? _refreshToken;
  int? _expiresAt;

  @override
  Future<void> clearToken() async {
    _token = null;
    _refreshToken = null;
    _expiresAt = null;
  }

  @override
  Future<int?> getExpiresAt() async => _expiresAt;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> setExpiresAt(int epochMs) async {
    _expiresAt = epochMs;
  }

  @override
  Future<void> setRefreshToken(String token) async {
    _refreshToken = token;
  }

  @override
  Future<void> setToken(String token) async {
    _token = token;
  }
}
