import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sebhua_notes/core/network/api_exception.dart';
import 'package:sebhua_notes/core/network/auth_interceptor.dart';
import 'package:sebhua_notes/core/network/error_interceptor.dart';
import 'package:sebhua_notes/core/network/token_refresher.dart';
import 'package:sebhua_notes/core/network/token_storage.dart';

void main() {
  test(
    '401 on protected path still refreshes through ErrorInterceptor chain',
    () async {
      final apiAdapter = _ApiAdapter();
      final harness = _createDioChain(apiAdapter);

      final response = await harness.dio.get<Map<String, Object?>>('/notes');

      expect(response.statusCode, 200);
      expect(response.data, {'ok': true});
      expect(harness.refreshAdapter.callCount, 1);
      expect(apiAdapter.authorizationHeaders, [
        'Bearer old-access',
        'Bearer new-access',
      ]);
    },
  );

  test(
    '401 on auth path does not refresh and rejects UnauthorizedException',
    () async {
      final apiAdapter = _Always401Adapter();
      final harness = _createDioChain(apiAdapter);

      await expectLater(
        harness.dio.post<Map<String, Object?>>('/auth/email/login'),
        throwsA(
          predicate<DioException>(
            (error) => error.error is UnauthorizedException,
          ),
        ),
      );
      expect(harness.refreshAdapter.callCount, 0);
      expect(apiAdapter.callCount, 1);
      expect(harness.storage.token, isNull);
      expect(harness.sessionExpiredCount(), 1);
    },
  );

  test('second 401 after retry does not refresh again', () async {
    final apiAdapter = _Always401Adapter();
    final harness = _createDioChain(apiAdapter);

    await expectLater(
      harness.dio.get<Map<String, Object?>>('/notes'),
      throwsA(
        predicate<DioException>(
          (error) => error.error is UnauthorizedException,
        ),
      ),
    );
    expect(harness.refreshAdapter.callCount, 1);
    expect(apiAdapter.callCount, 2);
    expect(apiAdapter.authorizationHeaders, [
      'Bearer old-access',
      'Bearer new-access',
    ]);
    expect(harness.storage.token, isNull);
    expect(harness.sessionExpiredCount(), 1);
  });

  test('refreshes once and retries the original request after a 401', () async {
    final storage = _MemoryTokenStorage()
      ..token = 'old-access'
      ..refreshToken = 'refresh-1';
    final refreshAdapter = _RefreshAdapter();
    final refreshDio = Dio()..httpClientAdapter = refreshAdapter;
    final tokenRefresher = TokenRefresher(
      tokenStorage: storage,
      refreshDio: refreshDio,
    );
    final apiAdapter = _ApiAdapter();
    final dio = Dio()..httpClientAdapter = apiAdapter;
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: storage,
        tokenRefresher: tokenRefresher,
        dio: dio,
      ),
    );

    final response = await dio.get<Map<String, Object?>>('/notes');

    expect(response.statusCode, 200);
    expect(response.data, {'ok': true});
    expect(refreshAdapter.callCount, 1);
    expect(apiAdapter.authorizationHeaders, [
      'Bearer old-access',
      'Bearer new-access',
    ]);
  });
}

({
  Dio dio,
  _MemoryTokenStorage storage,
  _RefreshAdapter refreshAdapter,
  int Function() sessionExpiredCount,
}) _createDioChain(HttpClientAdapter apiAdapter) {
  final storage = _MemoryTokenStorage()
    ..token = 'old-access'
    ..refreshToken = 'refresh-1';
  final refreshAdapter = _RefreshAdapter();
  final refreshDio = Dio()..httpClientAdapter = refreshAdapter;
  final tokenRefresher = TokenRefresher(
    tokenStorage: storage,
    refreshDio: refreshDio,
  );
  var sessionExpiredCount = 0;
  tokenRefresher.onSessionExpired = () {
    sessionExpiredCount += 1;
  };
  final dio = Dio()..httpClientAdapter = apiAdapter;
  dio.interceptors.addAll([
    AuthInterceptor(
      tokenStorage: storage,
      tokenRefresher: tokenRefresher,
      dio: dio,
    ),
    ErrorInterceptor(),
  ]);
  return (
    dio: dio,
    storage: storage,
    refreshAdapter: refreshAdapter,
    sessionExpiredCount: () => sessionExpiredCount,
  );
}

class _Always401Adapter implements HttpClientAdapter {
  int callCount = 0;
  final authorizationHeaders = <String?>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount += 1;
    authorizationHeaders.add(options.headers['Authorization'] as String?);

    return ResponseBody.fromString(
      jsonEncode({'message': 'Unauthorized'}),
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _ApiAdapter implements HttpClientAdapter {
  int callCount = 0;
  final authorizationHeaders = <String?>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount += 1;
    authorizationHeaders.add(options.headers['Authorization'] as String?);

    if (callCount == 1) {
      return ResponseBody.fromString(
        jsonEncode({'message': 'Unauthorized'}),
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _RefreshAdapter implements HttpClientAdapter {
  int callCount = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount += 1;
    expect(options.path, '/auth/refresh');

    return ResponseBody.fromString(
      jsonEncode({
        'code': 200,
        'message': 'OK',
        'data': {
          'accessToken': 'new-access',
          'refreshToken': 'refresh-2',
          'expiresIn': 120,
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _MemoryTokenStorage implements TokenStorage {
  String? token;
  String? refreshToken;
  int? expiresAt;

  @override
  Future<void> clearToken() async {
    token = null;
    refreshToken = null;
    expiresAt = null;
  }

  @override
  Future<int?> getExpiresAt() async => expiresAt;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> setExpiresAt(int epochMs) async {
    expiresAt = epochMs;
  }

  @override
  Future<void> setRefreshToken(String token) async {
    refreshToken = token;
  }

  @override
  Future<void> setToken(String token) async {
    this.token = token;
  }
}
