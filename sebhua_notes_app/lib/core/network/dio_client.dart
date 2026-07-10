import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'logging_interceptor.dart';
import 'token_refresher.dart';
import 'token_storage.dart';

/// Factory that builds a pre-configured [Dio] instance.
///
/// The client is set up with:
/// - [AppConstants.apiBaseUrl] as the base URL
/// - 30-second timeouts for connect, receive, and send
/// - JSON content-type headers
/// - [AuthInterceptor], [LoggingInterceptor], and [ErrorInterceptor]
class DioClient {
  DioClient._();

  /// Creates a new [Dio] instance wired with the standard interceptors.
  static Dio create({
    required TokenStorage tokenStorage,
    required TokenRefresher tokenRefresher,
  }) {
    final dio = Dio(_baseOptions());

    dio.interceptors.addAll([
      AuthInterceptor(
        tokenStorage: tokenStorage,
        tokenRefresher: tokenRefresher,
        dio: dio,
      ),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    return dio;
  }

  /// Creates a [Dio] instance for token refresh requests.
  ///
  /// This intentionally omits [AuthInterceptor] so refresh calls do not depend
  /// on an access token that may already be expired.
  static Dio createRefreshDio() {
    final dio = Dio(_baseOptions());

    dio.interceptors.addAll([
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    return dio;
  }

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(
        seconds: AppConstants.apiTimeoutSeconds,
      ),
      receiveTimeout: const Duration(
        seconds: AppConstants.apiTimeoutSeconds,
      ),
      sendTimeout: const Duration(
        seconds: AppConstants.apiTimeoutSeconds,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }
}
