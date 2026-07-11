import 'package:dio/dio.dart';

/// Service for WeChat callback API calls.
///
/// These endpoints are called by the WeChat server (not the app directly),
/// but are included here for completeness.
class WechatService {
  WechatService(this._dio);

  final Dio _dio;

  /// Verify WeChat callback (used during server configuration).
  ///
  /// GET /wechat/callback
  Future<Response<dynamic>> verifyCallback() async {
    return _dio.get<dynamic>('/wechat/callback');
  }

  /// Receive messages from WeChat server.
  ///
  /// POST /wechat/callback
  Future<Response<dynamic>> receiveMessage() async {
    return _dio.post<dynamic>('/wechat/callback');
  }
}
