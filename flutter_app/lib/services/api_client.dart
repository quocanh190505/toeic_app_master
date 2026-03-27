import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains('/auth/login') &&
              !e.requestOptions.path.contains('/auth/refresh')) {
            final refreshed = await _tryRefreshToken();

            if (refreshed) {
              final prefs = await SharedPreferences.getInstance();
              final newToken = prefs.getString('access_token');

              final retryRequest = await dio.fetch(
                e.requestOptions
                  ..headers['Authorization'] = 'Bearer $newToken',
              );
              return handler.resolve(retryRequest);
            }
          }

          handler.next(e);
        },
      ),
    );
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await Dio().post(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final data = response.data;
      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
      return true;
    } catch (_) {
      return false;
    }
  }
}