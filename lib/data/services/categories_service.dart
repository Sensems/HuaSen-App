import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/category_dto.dart';
import '../models/create_category_dto.dart';
import '../models/reorder_item.dart';
import '../models/update_category_dto.dart';

/// Service for category-related API calls.
class CategoriesService {
  CategoriesService(this._dio);

  final Dio _dio;

  /// Get the full category tree.
  ///
  /// GET /categories
  Future<ApiResponse<List<CategoryDto>>> getCategoryTree() async {
    final response = await _dio.get<Map<String, dynamic>>('/categories');
    return ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>)
          .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Create a new category.
  ///
  /// POST /categories/create
  Future<ApiResponse<CategoryDto>> createCategory(CreateCategoryDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/categories/create',
      data: dto.toJson(),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => CategoryDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update an existing category.
  ///
  /// POST /categories/update
  Future<ApiResponse<CategoryDto>> updateCategory(UpdateCategoryDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/categories/update',
      data: dto.toJson(),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => CategoryDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete a category.
  ///
  /// POST /categories/delete
  Future<ApiResponse<CategoryDto>> deleteCategory(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/categories/delete',
      data: <String, dynamic>{'id': id},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => CategoryDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Reorder categories.
  ///
  /// POST /categories/reorder
  Future<ApiResponse<void>> reorderCategories(List<ReorderItem> items) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/categories/reorder',
      data: <String, dynamic>{
        'items': items.map((e) => e.toJson()).toList(),
      },
    );
    return ApiResponse.fromJson(
      response.data!,
      (_) {},
    );
  }
}
