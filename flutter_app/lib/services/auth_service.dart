import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', response.data['access_token']);
    await prefs.setString('refresh_token', response.data['refresh_token']);

    final user = await me();

    await prefs.setString('role', user.role);
    await prefs.setString('full_name', user.fullName);
    await prefs.setString('email', user.email);

    return user;
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required int targetScore,
  }) async {
    await _dio.post(
      '/auth/register',
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'target_score': targetScore,
      },
    );
  }

  Future<UserModel> me() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.post(
      '/auth/change-password',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('role');
    await prefs.remove('full_name');
    await prefs.remove('email');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  Future<UserModel?> getStartupUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final user = await me();

      await prefs.setString('role', user.role);
      await prefs.setString('full_name', user.fullName);
      await prefs.setString('email', user.email);

      return user;
    } catch (_) {
      await logout();
      return null;
    }
  }
}