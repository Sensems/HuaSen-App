import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

/// Model representing an error payload returned by the backend.
@JsonSerializable()
class ApiError {
  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  /// HTTP status code or application-specific error code.
  final int code;

  /// Human-readable error description.
  final String message;

  /// Optional extra context (e.g. field-level validation errors).
  final Map<String, dynamic>? details;

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}
