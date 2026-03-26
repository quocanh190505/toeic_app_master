import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  bool _isLoggedIn = false;
  String? _token;
  int? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  int? get userId => _userId;

  AuthService() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    _userId = prefs.getInt('user_id');
    _isLoggedIn = _token != null && _token!.isNotEmpty;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final accessToken = response.data['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      final userId = _extractUserIdFromJwt(accessToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      if (userId != null) {
        await prefs.setInt('user_id', userId);
      }

      _token = accessToken;
      _userId = userId;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    int targetScore = 750,
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
      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');

    _token = null;
    _userId = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  int? _extractUserIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final sub = map['sub'];

      if (sub is String) return int.tryParse(sub);
      if (sub is int) return sub;
      return null;
    } catch (_) {
      return null;
    }
  }
}