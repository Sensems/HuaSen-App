import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

/// DTO for WeChat OAuth login callback.
@freezed
abstract class WechatCallbackDto with _$WechatCallbackDto {
  const factory WechatCallbackDto({
    required String code,
  }) = _WechatCallbackDto;

  factory WechatCallbackDto.fromJson(Map<String, dynamic> json) =>
      _$WechatCallbackDtoFromJson(json);
}

/// DTO for email/password login.
@freezed
abstract class EmailLoginDto with _$EmailLoginDto {
  const factory EmailLoginDto({
    required String email,
    required String password,
  }) = _EmailLoginDto;

  factory EmailLoginDto.fromJson(Map<String, dynamic> json) =>
      _$EmailLoginDtoFromJson(json);
}

/// DTO for token response after login or refresh.
@freezed
abstract class TokenResponseDto with _$TokenResponseDto {
  const factory TokenResponseDto({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) = _TokenResponseDto;

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseDtoFromJson(json);
}

/// DTO for refresh token request.
@freezed
abstract class RefreshTokenDto with _$RefreshTokenDto {
  const factory RefreshTokenDto({
    required String refreshToken,
  }) = _RefreshTokenDto;

  factory RefreshTokenDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenDtoFromJson(json);
}

/// DTO for logout response.
@freezed
abstract class LogoutResponseDto with _$LogoutResponseDto {
  const factory LogoutResponseDto({
    required bool success,
  }) = _LogoutResponseDto;

  factory LogoutResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LogoutResponseDtoFromJson(json);
}
