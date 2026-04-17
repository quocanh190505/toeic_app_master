import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  String _translateErrorMessage(String message) {
    const translations = {
      'Email hoặc mật khẩu không đúng.': 'Email hoặc mật khẩu không đúng.',
      'Email đã tồn tại trong hệ thống.': 'Email đã tồn tại trong hệ thống.',
      'Phiên đăng nhập không hợp lệ.': 'Phiên đăng nhập không hợp lệ.',
      'Không tìm thấy người dùng.': 'Không tìm thấy người dùng.',
      'Mật khẩu hiện tại không đúng.': 'Mật khẩu hiện tại không đúng.',
      'Phiên đăng nhập đã hết hạn.': 'Phiên đăng nhập đã hết hạn.',
      'Phiên đăng nhập đã bị thu hồi.': 'Phiên đăng nhập đã bị thu hồi.',
      'Bạn đang có một yêu cầu nâng cấp Premium chờ duyệt.':
          'Bạn đang có một yêu cầu nâng cấp Premium chờ duyệt.',
      'Đã gửi yêu cầu nâng cấp Premium. Vui lòng chờ kiểm duyệt.':
          'Đã gửi yêu cầu nâng cấp Premium. Vui lòng chờ kiểm duyệt.',
      'Gói Premium sẽ được hủy khi hết chu kỳ hiện tại.':
          'Gói Premium sẽ được hủy khi hết chu kỳ hiện tại.',
      'Đã hủy gói Premium thành công.': 'Đã hủy gói Premium thành công.',
    };

    return translations[message.trim()] ?? message.trim();
  }

  String _extractDioMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return _translateErrorMessage(detail);
      }

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return _translateErrorMessage(first['msg'].toString());
        }
      }

      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return _translateErrorMessage(message);
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return _translateErrorMessage(data);
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
        return 'Không thể kết nối tới máy chủ.';
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối tới máy chủ bị quá thời gian.';
      default:
        break;
    }

    if (error.response?.statusCode == 500) {
      return 'Máy chủ đang gặp lỗi. Vui lòng thử lại sau.';
    }

    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      return _extractDioMessage(error);
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
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

  Future<Map<String, dynamic>> requestPremiumUpgrade({
    required int months,
    String? transactionCode,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/premium-payment-requests',
        data: {
          'months': months,
          'transaction_code': transactionCode,
          'note': note,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Map<String, dynamic>>> getMyPremiumRequests() async {
    try {
      final response = await _dio.get('/auth/premium-payment-requests/me');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<UserModel> cancelPremium() async {
    try {
      await _dio.post('/auth/cancel-premium');
      return await me();
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
    if (token == null || token.isEmpty) return null;

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
