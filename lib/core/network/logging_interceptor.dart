import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that pretty-prints requests and responses in debug mode.
///
/// In release builds ([kDebugMode] == `false`) this interceptor is a no-op.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final startTime = DateTime.now();
      options.extra['__startTime'] = startTime;
      _log('➡️  REQUEST', '${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        _log('   Headers', options.headers.toString());
      }
      if (options.data != null) {
        _log('   Body', options.data.toString());
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final startTime = response.requestOptions.extra['__startTime'] as DateTime?;
      final elapsed = startTime != null
          ? DateTime.now().difference(startTime).inMilliseconds
          : null;
      _log(
        '✅ RESPONSE',
        '${response.statusCode} ${response.requestOptions.uri} '
        '${elapsed != null ? '(${elapsed}ms)' : ''}',
      );
      _log('   Body', response.data.toString());
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final startTime = err.requestOptions.extra['__startTime'] as DateTime?;
      final elapsed = startTime != null
          ? DateTime.now().difference(startTime).inMilliseconds
          : null;
      _log(
        '❌ ERROR',
        '${err.response?.statusCode ?? '---'} ${err.requestOptions.uri} '
        '${elapsed != null ? '(${elapsed}ms)' : ''}',
      );
      if (err.response?.data != null) {
        _log('   Body', err.response!.data.toString());
      }
    }
    handler.next(err);
  }

  void _log(String label, String message) {
    // ignore: avoid_print
    print('[$label] $message');
  }
}
