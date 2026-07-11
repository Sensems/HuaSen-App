/// Base class for all API-related exceptions.
///
/// Every concrete exception carries the HTTP [statusCode] and a human-readable
/// [message] so that UI layers can show meaningful feedback.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thrown when the server responds with 401 Unauthorized.
///
/// The auth interceptor catches this to clear the stored token and
/// trigger a redirect to the login screen.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({required super.message})
      : super(statusCode: 401);
}

/// Thrown when the server responds with 404 Not Found.
class NotFoundException extends ApiException {
  const NotFoundException({required super.message})
      : super(statusCode: 404);
}

/// Thrown when the server responds with 400 Bad Request (validation errors).
class ValidationException extends ApiException {
  const ValidationException({required super.message})
      : super(statusCode: 400);
}

/// Thrown when the server responds with 500 or any other 5xx error.
class ServerException extends ApiException {
  const ServerException({required super.message})
      : super(statusCode: 500);
}
