import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

String urlBase = "http://172.20.10.2:8000/api/v1/";
//String urlBase = "http://192.168.0.104:8000/api/v1/";

class UserService {
  static Future<bool> loginUser(String name, String password) async {
    try {
      // Авторизация
      final response = await Dio().post(
        '${urlBase}user/login',
        data: {
          'username': name,
          'password': password,
        },
        options: Options(
            contentType: Headers.formUrlEncodedContentType,
        ),
      );
      print('Отправляем на сервер: $name / $password');

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('refresh_token', refreshToken);

        print('Токены сохранены: $token / $refreshToken');
        return true;
      } else {
        print('Ошибка логина: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) return false;

    try {
      final response = await Dio().post(
        '${urlBase}user/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        await prefs.setString('auth_token', newAccessToken);
        await prefs.setString('refresh_token', newRefreshToken);
        print('Токены обновлены');
        return true;
      }
    } catch (e) {
      print('Ошибка при обновлении токена: $e');
    }

    return false;
  }


  Future<void> MeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception('Пользователь не авторизован');

    try {
      final response = await Dio().get(
        '${urlBase}user/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final user = response.data;
      print("Текущий пользователь: ${user['username']}");
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          return MeUser();
        }
      }
      print('Ошибка MeUser: ${e.response?.data ?? e.message}');
    }
  }

  static Future<void> deleteUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) throw Exception('Пользователь не авторизован');

      final deleteRes = await Dio().delete(
        '${urlBase}user/me',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      print("Пользователь успешно удалён: ${deleteRes.data['message']}");
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Ошибка: $e');
    }
  }
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }

  static Future<bool> registerUser(String username, String password) async {
    try {
      await Dio().post(
        '${urlBase}user/register',
        data: {'username': username, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return await loginUser(username, password);
    } catch (e) {
      return false;
    }
  }
}
