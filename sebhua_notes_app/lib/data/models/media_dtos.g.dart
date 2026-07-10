// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaDto _$MediaDtoFromJson(Map<String, dynamic> json) => _MediaDto(
  mediaId: json['mediaId'] as String,
  key: json['key'] as String,
  url: json['url'] as String,
  mimeType: json['mimeType'] as String,
  size: (json['size'] as num).toInt(),
  type: $enumDecodeNullable(_$MediaTypeEnumMap, json['type']),
  createdAt: _dateTimeFromJsonNullable(json['createdAt'] as String?),
);

Map<String, dynamic> _$MediaDtoToJson(_MediaDto instance) => <String, dynamic>{
  'mediaId': instance.mediaId,
  'key': instance.key,
  'url': instance.url,
  'mimeType': instance.mimeType,
  'size': instance.size,
  'type': _$MediaTypeEnumMap[instance.type],
  'createdAt': _dateTimeToJsonNullable(instance.createdAt),
};

const _$MediaTypeEnumMap = {
  MediaType.image: 'IMAGE',
  MediaType.voice: 'VOICE',
  MediaType.video: 'VIDEO',
  MediaType.file: 'FILE',
};

_CheckMediaDto _$CheckMediaDtoFromJson(Map<String, dynamic> json) =>
    _CheckMediaDto(
      mediaIds: (json['mediaIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CheckMediaDtoToJson(_CheckMediaDto instance) =>
    <String, dynamic>{'mediaIds': instance.mediaIds};

_CheckMediaResultDto _$CheckMediaResultDtoFromJson(Map<String, dynamic> json) =>
    _CheckMediaResultDto(
      validIds: (json['validIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      invalidIds: (json['invalidIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CheckMediaResultDtoToJson(
  _CheckMediaResultDto instance,
) => <String, dynamic>{
  'validIds': instance.validIds,
  'invalidIds': instance.invalidIds,
};
