// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadTokenResponseDto _$UploadTokenResponseDtoFromJson(
  Map<String, dynamic> json,
) => _UploadTokenResponseDto(token: json['token'] as String);

Map<String, dynamic> _$UploadTokenResponseDtoToJson(
  _UploadTokenResponseDto instance,
) => <String, dynamic>{'token': instance.token};

_UploadFileResponseDto _$UploadFileResponseDtoFromJson(
  Map<String, dynamic> json,
) => _UploadFileResponseDto(
  mediaId: json['mediaId'] as String,
  key: json['key'] as String,
  url: json['url'] as String,
  mimeType: json['mimeType'] as String,
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$UploadFileResponseDtoToJson(
  _UploadFileResponseDto instance,
) => <String, dynamic>{
  'mediaId': instance.mediaId,
  'key': instance.key,
  'url': instance.url,
  'mimeType': instance.mimeType,
  'size': instance.size,
};

_DeleteFileDto _$DeleteFileDtoFromJson(Map<String, dynamic> json) =>
    _DeleteFileDto(key: json['key'] as String);

Map<String, dynamic> _$DeleteFileDtoToJson(_DeleteFileDto instance) =>
    <String, dynamic>{'key': instance.key};

_DeleteFileResponseDto _$DeleteFileResponseDtoFromJson(
  Map<String, dynamic> json,
) => _DeleteFileResponseDto(success: json['success'] as bool);

Map<String, dynamic> _$DeleteFileResponseDtoToJson(
  _DeleteFileResponseDto instance,
) => <String, dynamic>{'success': instance.success};
