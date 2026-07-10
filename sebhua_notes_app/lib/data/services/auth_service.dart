import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/auth_dtos.dart' show EmailLoginDto;
import '../models/logout_response_dto.dart';
import '../models/token_response_dto.dart';
import '../models/wechat_callback_dto.dart';

/// Service for authentication-related API calls.
class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  /// WeChat OAuth login.
  ///
  /// POST /auth/wechat/callback
  Future<ApiResponse<TokenResponseDto>> wechatLogin(String code) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/wechat/callback',
      data: WechatCallbackDto(code: code).toJson(),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => TokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Email/password login.
  ///
  /// POST /auth/email/login
  Future<ApiResponse<TokenResponseDto>> emailLogin({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/email/login',
      data: EmailLoginDto(email: email, password: password).toJson(),
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => TokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Refresh access token.
  ///
  /// POST /auth/refresh
  Future<ApiResponse<TokenResponseDto>> refreshToken(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return ApiResponse.fromJson(
      response.data!,
      (json) => TokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Logout the current user.
  ///
  /// POST /auth/logout
  Future<ApiResponse<LogoutResponseDto>> logout() async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/logout');
    return ApiResponse.fromJson(
      response.data!,
      (json) => LogoutResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
