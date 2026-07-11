import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Interceptor that converts [DioException] instances into typed domain
/// exceptions based on the HTTP status code.
///
/// Mapping:
/// - 400 → [ValidationException]
/// - 401 → passed through for [AuthInterceptor] refresh/retry handling
/// - 404 → [NotFoundException]
/// - 5xx → [ServerException]
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401) {
      // Dio invokes onError in reverse order, so keep 401s available for auth.
      handler.next(err);
      return;
    }

    final message = _extractMessage(err);

    final ApiException exception;
    if (statusCode == null) {
      exception = ApiException(statusCode: 0, message: message);
    } else if (statusCode == 400) {
      exception = ValidationException(message: message);
    } else if (statusCode == 404) {
      exception = NotFoundException(message: message);
    } else if (statusCode >= 500 && statusCode <= 599) {
      exception = ServerException(message: message);
    } else {
      exception = ApiException(statusCode: statusCode, message: message);
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  String _extractMessage(DioException err) {
    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? 'Request failed') as String;
    }
    return err.message ?? 'Request failed';
  }
}
