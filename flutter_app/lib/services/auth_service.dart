import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  String _translateErrorMessage(String message) {
    const translations = {
      'Invalid email or password': 'Email hoặc mật khẩu không đúng.',
      'Email already exists': 'Email này đã được sử dụng.',
      'Invalid token': 'Phiên đăng nhập không hợp lệ.',
      'User not found': 'Không tìm thấy người dùng.',
      'Old password is incorrect': 'Mật khẩu hiện tại không đúng.',
      'Refresh token not found': 'Phiên đăng nhập đã hết hạn.',
      'Refresh token revoked': 'Phiên đăng nhập đã bị thu hồi.',
      'Refresh token expired': 'Phiên đăng nhập đã hết hạn.',
      'Invalid refresh token payload': 'Phiên đăng nhập không hợp lệ.',
    };

    return translations[message] ?? message;
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final detail = error.response!.data['detail'];
        if (detail is String) {
          return _translateErrorMessage(detail);
        } else if (detail is List && detail.isNotEmpty) {
          final message = detail.first['msg'] ?? 'Dữ liệu không hợp lệ.';
          if (message is String) {
            return _translateErrorMessage(message);
          }
        }
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Không thể kết nối tới máy chủ!';
      }
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại!';
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
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
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required int targetScore,
  }) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'target_score': targetScore,
        },
      );
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<UserModel> me() async {
    try {
      final response = await _dio.get('/auth/me');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      throw Exception(_handleError(e));
    }
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
