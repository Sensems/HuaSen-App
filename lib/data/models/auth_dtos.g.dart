// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WechatCallbackDto _$WechatCallbackDtoFromJson(Map<String, dynamic> json) =>
    _WechatCallbackDto(code: json['code'] as String);

Map<String, dynamic> _$WechatCallbackDtoToJson(_WechatCallbackDto instance) =>
    <String, dynamic>{'code': instance.code};

_EmailLoginDto _$EmailLoginDtoFromJson(Map<String, dynamic> json) =>
    _EmailLoginDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$EmailLoginDtoToJson(_EmailLoginDto instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_EmailSendCodeDto _$EmailSendCodeDtoFromJson(Map<String, dynamic> json) =>
    _EmailSendCodeDto(
      email: json['email'] as String,
      purpose: $enumDecode(_$EmailCodePurposeEnumMap, json['purpose']),
    );

Map<String, dynamic> _$EmailSendCodeDtoToJson(_EmailSendCodeDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'purpose': _$EmailCodePurposeEnumMap[instance.purpose]!,
    };

const _$EmailCodePurposeEnumMap = {
  EmailCodePurpose.register: 'register',
  EmailCodePurpose.resetPassword: 'reset_password',
};

_EmailRegisterDto _$EmailRegisterDtoFromJson(Map<String, dynamic> json) =>
    _EmailRegisterDto(
      email: json['email'] as String,
      password: json['password'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$EmailRegisterDtoToJson(_EmailRegisterDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'code': instance.code,
    };

_EmailResetPasswordDto _$EmailResetPasswordDtoFromJson(
  Map<String, dynamic> json,
) => _EmailResetPasswordDto(
  email: json['email'] as String,
  password: json['password'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$EmailResetPasswordDtoToJson(
  _EmailResetPasswordDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'code': instance.code,
};

_TokenResponseDto _$TokenResponseDtoFromJson(Map<String, dynamic> json) =>
    _TokenResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
    );

Map<String, dynamic> _$TokenResponseDtoToJson(_TokenResponseDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
    };

_RefreshTokenDto _$RefreshTokenDtoFromJson(Map<String, dynamic> json) =>
    _RefreshTokenDto(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshTokenDtoToJson(_RefreshTokenDto instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};

_LogoutResponseDto _$LogoutResponseDtoFromJson(Map<String, dynamic> json) =>
    _LogoutResponseDto(success: json['success'] as bool);

Map<String, dynamic> _$LogoutResponseDtoToJson(_LogoutResponseDto instance) =>
    <String, dynamic>{'success': instance.success};
