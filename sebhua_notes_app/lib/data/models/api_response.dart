import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic wrapper for every API response.
///
/// The backend always returns responses in this shape:
/// ```json
/// {
///   "code": 200,
///   "message": "OK",
///   "data": { ... }
/// }
/// ```
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  /// HTTP status code returned by the server.
  final int code;

  /// Human-readable status message.
  final String message;

  /// Typed payload.  May be `null` for empty responses.
  final T? data;

  /// Convenience getter that checks whether [code] equals 200.
  bool get isSuccess => code == 200;

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
