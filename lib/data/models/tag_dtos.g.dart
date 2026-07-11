// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TagResponseDto _$TagResponseDtoFromJson(Map<String, dynamic> json) =>
    _TagResponseDto(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: _dateTimeFromJson(json['createdAt'] as String),
      notesCount: _notesCountFromJson(json['_count']),
    );

Map<String, dynamic> _$TagResponseDtoToJson(_TagResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': _dateTimeToJson(instance.createdAt),
      '_count': _notesCountToJson(instance.notesCount),
    };

_CreateTagDto _$CreateTagDtoFromJson(Map<String, dynamic> json) =>
    _CreateTagDto(name: json['name'] as String);

Map<String, dynamic> _$CreateTagDtoToJson(_CreateTagDto instance) =>
    <String, dynamic>{'name': instance.name};
