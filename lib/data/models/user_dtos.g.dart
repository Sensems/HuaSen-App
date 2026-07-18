// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    _UserProfileDto(
      id: json['id'] as String?,
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      wxBound: json['wxBound'] as bool?,
    );

Map<String, dynamic> _$UserProfileDtoToJson(_UserProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'wxBound': instance.wxBound,
    };

_UpdateProfileDto _$UpdateProfileDtoFromJson(Map<String, dynamic> json) =>
    _UpdateProfileDto(
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$UpdateProfileDtoToJson(_UpdateProfileDto instance) =>
    <String, dynamic>{
      'nickname': ?instance.nickname,
      'avatar': ?instance.avatar,
    };

_BindUserDto _$BindUserDtoFromJson(Map<String, dynamic> json) =>
    _BindUserDto(bindingCode: json['bindingCode'] as String);

Map<String, dynamic> _$BindUserDtoToJson(_BindUserDto instance) =>
    <String, dynamic>{'bindingCode': instance.bindingCode};
