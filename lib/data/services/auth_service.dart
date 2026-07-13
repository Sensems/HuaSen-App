import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/auth_dtos.dart';

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

  /// Send email verification code.
  ///
  /// POST /auth/email/send-code
  Future<ApiResponse<void>> sendEmailCode({
    required String email,
    required EmailCodePurpose purpose,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/email/send-code',
      data: EmailSendCodeDto(email: email, purpose: purpose).toJson(),
    );
    return ApiResponse.fromJson(response.data!, (_) {});
  }

  /// Email registration.
  ///
  /// POST /auth/email/register
  ///
  /// OpenAPI documents a success response without token payload. Callers must
  /// not persist tokens or auto-login after register.
  Future<ApiResponse<void>> emailRegister({
    required String email,
    required String password,
    required String code,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/email/register',
      data: EmailRegisterDto(
        email: email,
        password: password,
        code: code,
      ).toJson(),
    );
    return ApiResponse.fromJson(response.data!, (_) {});
  }

  /// Reset password with email verification code.
  ///
  /// POST /auth/email/reset-password
  Future<ApiResponse<void>> emailResetPassword({
    required String email,
    required String password,
    required String code,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/email/reset-password',
      data: EmailResetPasswordDto(
        email: email,
        password: password,
        code: code,
      ).toJson(),
    );
    return ApiResponse.fromJson(response.data!, (_) {});
  }

  /// Refresh access token.
  ///
  /// POST /auth/refresh
  Future<ApiResponse<TokenResponseDto>> refreshToken(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: RefreshTokenDto(refreshToken: refreshToken).toJson(),
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
