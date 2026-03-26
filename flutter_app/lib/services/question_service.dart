import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/question_model.dart';

class QuestionService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<List<QuestionModel>> getQuestions({int? part}) async {
    try {
      final response = await _dio.get(
        '/questions',
        queryParameters: {
          if (part != null) 'part': part,
        },
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('DATA: ${response.data}');

      if (response.data is! List) {
        throw Exception('API không trả về List. response.data = ${response.data}');
      }

      final data = response.data as List;

      return data
          .map((item) => QuestionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.message}');
      debugPrint('Dio response: ${e.response?.data}');
      throw Exception('Lỗi gọi API: ${e.message}');
    } catch (e) {
      debugPrint('Parse error: $e');
      rethrow;
    }
  }
}