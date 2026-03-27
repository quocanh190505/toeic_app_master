import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/question_model.dart';
import 'api_client.dart';

class QuestionService {
  final Dio _dio = ApiClient().dio;

  Future<List<QuestionModel>> getQuestions({int? part}) async {
    try {
      final response = await _dio.get(
        '/questions',
        queryParameters: {
          if (part != null) 'part': part,
        },
      );

      debugPrint('URL: ${response.requestOptions.uri}');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('DATA: ${response.data}');

      if (response.data is! List) {
        throw Exception(
          'API không trả về List. response.data = ${response.data}',
        );
      }

      final data = response.data as List;

      return data
          .map((item) => QuestionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.message}');
      debugPrint('Error URL: ${e.requestOptions.uri}');
      debugPrint('Error status: ${e.response?.statusCode}');
      debugPrint('Error data: ${e.response?.data}');
      throw Exception(
        e.response?.data?['detail']?.toString() ??
            'Lỗi gọi API: ${e.message}',
      );
    } catch (e) {
      debugPrint('Parse error: $e');
      rethrow;
    }
  }
}