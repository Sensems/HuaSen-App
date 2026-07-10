import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/tag_response_dto.dart';

/// Service for tag-related API calls.
class TagsService {
  TagsService(this._dio);

  final Dio _dio;

  /// Get all tags.
  ///
  /// GET /tags
  Future<ApiResponse<List<TagResponseDto>>> getTags() async {
    final response = await _dio.get<Map<String, dynamic>>('/tags');
    return ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>)
          .map((e) => TagResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Create a new tag.
  ///
  /// POST /tags/create
  Future<ApiResponse<TagResponseDto>> createTag(String name) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/tags/create',
      data: <String, dynamic>{'name': name},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => TagResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete a tag.
  ///
  /// POST /tags/delete
  Future<ApiResponse<TagResponseDto>> deleteTag(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/tags/delete',
      data: <String, dynamic>{'id': id},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => TagResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
