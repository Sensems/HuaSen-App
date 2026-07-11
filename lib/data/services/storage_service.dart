import 'dart:io';

import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/delete_file_response_dto.dart';
import '../models/upload_file_response_dto.dart';
import '../models/upload_token_response_dto.dart';

/// Service for storage-related API calls (file upload, tokens, deletion).
class StorageService {
  StorageService(this._dio);

  final Dio _dio;

  /// Get a pre-signed upload token.
  ///
  /// GET /storage/upload-token?key={key}
  Future<ApiResponse<UploadTokenResponseDto>> getUploadToken({String? key}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/storage/upload-token',
      queryParameters: <String, dynamic>{
        'key': key,
      }..removeWhere((_, v) => v == null),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => UploadTokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Upload a file via multipart form.
  ///
  /// POST /storage/upload
  Future<ApiResponse<UploadFileResponseDto>> uploadFile(
    File file, {
    String? type,
  }) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(file.path),
      'type': type,
    }..removeWhere((_, v) => v == null));
    final response = await _dio.post<Map<String, dynamic>>(
      '/storage/upload',
      data: formData,
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => UploadFileResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete a file by key.
  ///
  /// POST /storage/delete
  Future<ApiResponse<DeleteFileResponseDto>> deleteFile(String key) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/storage/delete',
      data: <String, dynamic>{'key': key},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => DeleteFileResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
