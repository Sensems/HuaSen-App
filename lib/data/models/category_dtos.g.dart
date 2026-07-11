// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryDto _$CategoryDtoFromJson(Map<String, dynamic> json) => _CategoryDto(
  id: json['id'] as String,
  name: json['name'] as String,
  parentId: json['parentId'] as String?,
  sortOrder: (json['sortOrder'] as num).toInt(),
  notesCount: (json['notesCount'] as num).toInt(),
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryDtoToJson(_CategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentId': instance.parentId,
      'sortOrder': instance.sortOrder,
      'notesCount': instance.notesCount,
      'children': instance.children,
    };

_CreateCategoryDto _$CreateCategoryDtoFromJson(Map<String, dynamic> json) =>
    _CreateCategoryDto(
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
    );

Map<String, dynamic> _$CreateCategoryDtoToJson(_CreateCategoryDto instance) =>
    <String, dynamic>{'name': instance.name, 'parentId': instance.parentId};

_UpdateCategoryDto _$UpdateCategoryDtoFromJson(Map<String, dynamic> json) =>
    _UpdateCategoryDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      parentId: json['parentId'] as String?,
    );

Map<String, dynamic> _$UpdateCategoryDtoToJson(_UpdateCategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentId': instance.parentId,
    };

_ReorderItem _$ReorderItemFromJson(Map<String, dynamic> json) => _ReorderItem(
  id: json['id'] as String,
  parentId: json['parentId'] as String?,
);

Map<String, dynamic> _$ReorderItemToJson(_ReorderItem instance) =>
    <String, dynamic>{'id': instance.id, 'parentId': instance.parentId};

_ReorderCategoryDto _$ReorderCategoryDtoFromJson(Map<String, dynamic> json) =>
    _ReorderCategoryDto(
      items: (json['items'] as List<dynamic>)
          .map((e) => ReorderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReorderCategoryDtoToJson(_ReorderCategoryDto instance) =>
    <String, dynamic>{'items': instance.items};
