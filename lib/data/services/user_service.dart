import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/user_dtos.dart';

/// Service for user profile and binding API calls.
///
/// All methods require JWT authentication (handled by [AuthInterceptor]).
class UserService {
  UserService(this._dio);

  final Dio _dio;

  /// Get the current user's profile.
  ///
  /// GET /user/profile
  Future<ApiResponse<UserProfileDto>> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/user/profile');
    return ApiResponse.fromJson(
      response.data!,
      (json) => UserProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update nickname and/or avatar URL.
  ///
  /// POST /user/update
  Future<ApiResponse<UserProfileDto>> updateProfile(UpdateProfileDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/user/update',
      data: dto.toJson(),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => UserProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Bind WeChat to the current account with a binding code.
  ///
  /// POST /user/bind
  Future<ApiResponse<void>> bindWechat(BindUserDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/user/bind',
      data: dto.toJson(),
    );
    return ApiResponse.fromJson(response.data!, (_) {});
  }
}
