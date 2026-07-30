import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dtos.freezed.dart';
part 'user_dtos.g.dart';

/// Current user profile (`GET /user/profile` → `UserProfileResponseDto`).
@freezed
abstract class UserProfileDto with _$UserProfileDto {
  const factory UserProfileDto({
    String? id,
    String? email,
    String? nickname,
    String? avatar,
    /// 6-digit code for WeChat official-account binding when unbound.
    String? bindingCode,
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

/// Response payload for `POST /user/bind` (`BindUserResponseDto`).
@freezed
abstract class BindUserResponseDto with _$BindUserResponseDto {
  const factory BindUserResponseDto({
    required bool wxBound,
    required int syncedDraftCount,
    required bool overwritten,
    required String message,
  }) = _BindUserResponseDto;

  factory BindUserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BindUserResponseDtoFromJson(json);
}

/// Response payload for `POST /user/unbind` (`UnbindWechatResponseDto`).
@freezed
abstract class UnbindWechatResponseDto with _$UnbindWechatResponseDto {
  const factory UnbindWechatResponseDto({
    required bool wxBound,
    required String message,
  }) = _UnbindWechatResponseDto;

  factory UnbindWechatResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UnbindWechatResponseDtoFromJson(json);
}
