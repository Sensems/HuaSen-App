import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dtos.freezed.dart';
part 'user_dtos.g.dart';

/// Current user profile (`GET /user/profile`).
///
/// OpenAPI does not publish a response schema; fields are optional so unknown
/// or partial payloads still decode.
@freezed
abstract class UserProfileDto with _$UserProfileDto {
  const factory UserProfileDto({
    String? id,
    String? email,
    String? nickname,
    String? avatar,
    bool? wxBound,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}

/// DTO for updating nickname and/or avatar (`POST /user/update`).
@freezed
abstract class UpdateProfileDto with _$UpdateProfileDto {
  const factory UpdateProfileDto({
    @JsonKey(includeIfNull: false) String? nickname,
    @JsonKey(includeIfNull: false) String? avatar,
  }) = _UpdateProfileDto;

  factory UpdateProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileDtoFromJson(json);
}

/// DTO for binding WeChat via binding code (`POST /user/bind`).
@freezed
abstract class BindUserDto with _$BindUserDto {
  const factory BindUserDto({
    required String bindingCode,
  }) = _BindUserDto;

  factory BindUserDto.fromJson(Map<String, dynamic> json) =>
      _$BindUserDtoFromJson(json);
}
