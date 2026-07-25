import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_dtos.freezed.dart';
part 'category_dtos.g.dart';

/// Wire `_count: { notes: N }` (or a bare number / legacy `notesCount`) → int.
int _notesCountFromJson(Object? json) {
  if (json == null) return 0;
  if (json is num) return json.toInt();
  if (json is Map) {
    final dynamic direct = json['notes'] ?? json['Note'] ?? json['notesCount'];
    if (direct is num) return direct.toInt();
    for (final value in json.values) {
      if (value is num) return value.toInt();
    }
  }
  return 0;
}

Object? _notesCountToJson(int count) => <String, dynamic>{'notes': count};

/// Prefer `_count`, fall back to legacy top-level `notesCount`.
Object? _readNotesCount(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['notesCount'];

DateTime? _dateTimeFromJsonNullable(String? json) =>
    json == null ? null : DateTime.parse(json);

String? _dateTimeToJsonNullable(DateTime? dateTime) =>
    dateTime?.toIso8601String();

/// DTO representing a category in the tree.
@freezed
abstract class CategoryDto with _$CategoryDto {
  const factory CategoryDto({
    required String id,
    String? userId,
    required String name,
    String? parentId,
    required int sortOrder,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? createdAt,
    @JsonKey(
      name: '_count',
      fromJson: _notesCountFromJson,
      toJson: _notesCountToJson,
      readValue: _readNotesCount,
    )
    required int notesCount,
    List<CategoryDto>? children,
  }) = _CategoryDto;

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);
}

/// DTO for creating a new category.
@freezed
abstract class CreateCategoryDto with _$CreateCategoryDto {
  const factory CreateCategoryDto({
    required String name,
    String? parentId,
  }) = _CreateCategoryDto;

  factory CreateCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCategoryDtoFromJson(json);
}

/// DTO for updating an existing category.
@freezed
abstract class UpdateCategoryDto with _$UpdateCategoryDto {
  const factory UpdateCategoryDto({
    required String id,
    String? name,
    String? parentId,
  }) = _UpdateCategoryDto;

  factory UpdateCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCategoryDtoFromJson(json);
}

/// DTO for a single reorder item.
@freezed
abstract class ReorderItem with _$ReorderItem {
  const factory ReorderItem({
    required String id,
    String? parentId,
  }) = _ReorderItem;

  factory ReorderItem.fromJson(Map<String, dynamic> json) =>
      _$ReorderItemFromJson(json);
}

/// DTO for reordering categories.
@freezed
abstract class ReorderCategoryDto with _$ReorderCategoryDto {
  const factory ReorderCategoryDto({
    required List<ReorderItem> items,
  }) = _ReorderCategoryDto;

  factory ReorderCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$ReorderCategoryDtoFromJson(json);
}
