import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/check_media_result_dto.dart';

/// Service for media-related API calls.
class MediaService {
  MediaService(this._dio);

  final Dio _dio;

  /// Check whether a list of media IDs exist on the server.
  ///
  /// POST /media/check
  Future<ApiResponse<CheckMediaResultDto>> checkMediaIds(List<String> mediaIds) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/media/check',
      data: <String, dynamic>{'mediaIds': mediaIds},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => CheckMediaResultDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
