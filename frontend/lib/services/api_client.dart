import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calmera/services/user_service.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(baseUrl: urlBase));

  static Future<Response> get(String path) async {
    return _sendRequest(() async => _dio.get(path, options: await _authHeader()));
  }

  static Future<Response> post(String path, Map<String, dynamic> data) async {
    return _sendRequest(() async => _dio.post(path, data: data, options: await _authHeader()));
  }

  static Future<Response> put(String path, Map<String, dynamic> data) async {
    return _sendRequest(() async => _dio.put(path, data: data, options: await _authHeader()));
  }

  static Future<Response> delete(String path) async {
    return _sendRequest(() async => _dio.delete(path, options: await _authHeader()));
  }

  static Future<Response> _sendRequest(Future<Response> Function() requestFn) async {
    try {
      return await requestFn();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final refreshed = await UserService.refreshToken();
        if (refreshed) {
          return await requestFn();
        }
      }
      rethrow;
    }
  }

  static Future<Options> _authHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }
}
