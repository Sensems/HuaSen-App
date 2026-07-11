import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'token_refresher.dart';
import 'token_storage.dart';

/// Interceptor that injects the JWT Bearer token into every request.
///
/// [ErrorInterceptor] lets 401 responses pass through so this interceptor can
/// refresh the token once and retry the failed request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.tokenRefresher,
    required this.dio,
  });

  final TokenStorage tokenStorage;
  final TokenRefresher tokenRefresher;
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final message = _extractMessage(err);
      if (_isAuthPath(err.requestOptions.path) ||
          err.requestOptions.extra['__authRetry'] == true) {
        await tokenRefresher.expireSession();
        return _rejectUnauthorized(err, handler, message);
      }

      final refreshed = await tokenRefresher.refresh();
      if (!refreshed) {
        return _rejectUnauthorized(err, handler, message);
      }

      final token = await tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return _rejectUnauthorized(err, handler, message);
      }

      err.requestOptions
        ..headers['Authorization'] = 'Bearer $token'
        ..extra['__authRetry'] = true;
      return handler.resolve(await dio.fetch<dynamic>(err.requestOptions));
    }
    handler.next(err);
  }

  void _rejectUnauthorized(
    DioException err,
    ErrorInterceptorHandler handler,
    String message,
  ) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: UnauthorizedException(message: message),
      ),
    );
  }

  bool _isAuthPath(String path) {
    final uriPath = Uri.tryParse(path)?.path ?? path;
    // Auth endpoints cannot recover by calling refresh again.
    return uriPath.startsWith('/auth/');
  }

  String _extractMessage(DioException err) {
    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? 'Unauthorized').toString();
    }
    return err.message ?? 'Unauthorized';
  }
}
