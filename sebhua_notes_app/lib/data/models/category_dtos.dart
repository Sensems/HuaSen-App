import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_dtos.freezed.dart';
part 'category_dtos.g.dart';

/// DTO representing a category in the tree.
@freezed
abstract class CategoryDto with _$CategoryDto {
  const factory CategoryDto({
    required String id,
    required String name,
    String? parentId,
    required int sortOrder,
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
