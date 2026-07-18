// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateNoteDto _$CreateNoteDtoFromJson(Map<String, dynamic> json) =>
    _CreateNoteDto(
      title: json['title'] as String?,
      content: json['content'] as String?,
      source: $enumDecodeNullable(_$NoteSourceEnumMap, json['source']),
      categoryId: json['categoryId'] as String?,
      tagIds: (json['tagIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mediaIds: (json['mediaIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateNoteDtoToJson(_CreateNoteDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'source': _$NoteSourceEnumMap[instance.source],
      'categoryId': instance.categoryId,
      'tagIds': instance.tagIds,
      'mediaIds': instance.mediaIds,
    };

const _$NoteSourceEnumMap = {
  NoteSource.wechat: 'WECHAT',
  NoteSource.appClipboard: 'APP_CLIPBOARD',
  NoteSource.appManual: 'APP_MANUAL',
};

_UpdateNoteDto _$UpdateNoteDtoFromJson(Map<String, dynamic> json) =>
    _UpdateNoteDto(
      id: json['id'] as String,
      title: json['title'] as String?,
      content: json['content'] as String?,
      categoryId: json['categoryId'] as String?,
      tagIds: (json['tagIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mediaIds: (json['mediaIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UpdateNoteDtoToJson(_UpdateNoteDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'categoryId': instance.categoryId,
      'tagIds': instance.tagIds,
      'mediaIds': instance.mediaIds,
    };

_NoteMetaDto _$NoteMetaDtoFromJson(Map<String, dynamic> json) => _NoteMetaDto(
  mediaUrl: json['media_url'] as String?,
  mediaType: json['media_type'] as String?,
);

Map<String, dynamic> _$NoteMetaDtoToJson(_NoteMetaDto instance) =>
    <String, dynamic>{
      'media_url': instance.mediaUrl,
      'media_type': instance.mediaType,
    };

_NoteDetailDto _$NoteDetailDtoFromJson(Map<String, dynamic> json) =>
    _NoteDetailDto(
      id: json['id'] as String,
      title: json['title'] as String?,
      content: json['content'] as String?,
      source: $enumDecodeNullable(_$NoteSourceEnumMap, json['source']),
      type: json['type'] as String?,
      categoryId: json['categoryId'] as String?,
      tagIds: (json['tagIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mediaIds: (json['mediaIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      meta: json['meta'] == null
          ? null
          : NoteMetaDto.fromJson(json['meta'] as Map<String, dynamic>),
      pinnedAt: _dateTimeFromJsonNullable(json['pinnedAt'] as String?),
      createdAt: _dateTimeFromJsonNullable(json['createdAt'] as String?),
      updatedAt: _dateTimeFromJsonNullable(json['updatedAt'] as String?),
    );

Map<String, dynamic> _$NoteDetailDtoToJson(_NoteDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'source': _$NoteSourceEnumMap[instance.source],
      'type': instance.type,
      'categoryId': instance.categoryId,
      'tagIds': instance.tagIds,
      'mediaIds': instance.mediaIds,
      'meta': instance.meta,
      'pinnedAt': _dateTimeToJsonNullable(instance.pinnedAt),
      'createdAt': _dateTimeToJsonNullable(instance.createdAt),
      'updatedAt': _dateTimeToJsonNullable(instance.updatedAt),
    };

_PaginatedNotes _$PaginatedNotesFromJson(Map<String, dynamic> json) =>
    _PaginatedNotes(
      items: (json['items'] as List<dynamic>)
          .map((e) => NoteDetailDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedNotesToJson(_PaginatedNotes instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'size': instance.size,
    };

_ShareInfoDto _$ShareInfoDtoFromJson(Map<String, dynamic> json) =>
    _ShareInfoDto(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String?,
      shareUrl: json['shareUrl'] as String,
    );

Map<String, dynamic> _$ShareInfoDtoToJson(_ShareInfoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': instance.type,
      'shareUrl': instance.shareUrl,
    };
