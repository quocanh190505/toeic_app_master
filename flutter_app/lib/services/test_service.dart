import 'package:dio/dio.dart';

import '../../models/attempt_model.dart';
import '../../models/question_model.dart';
import 'api_client.dart';

class TestService {
  final Dio _dio = ApiClient().dio;

  static const List<int> validMiniTestParts = [1, 2, 3, 4, 5, 6, 7];

  void _validateMiniTestPart(int part) {
    if (!validMiniTestParts.contains(part)) {
      throw Exception(
        'part không hợp lệ. Chỉ chấp nhận: ${validMiniTestParts.join(', ')}',
      );
    }
  }

  Future<List<QuestionModel>> getMiniTest({required int part}) async {
    _validateMiniTestPart(part);

    try {
      final response = await _dio.get(
        '/questions/mini-test',
        queryParameters: {'part': part},
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response mini-test không đúng format: $data');
      }

      if (data['questions'] is! List) {
        throw Exception('Response mini-test thiếu questions: $data');
      }

      final list = data['questions'] as List;

      return list
          .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      print('MINI TEST URL: ${e.requestOptions.uri}');
      print('MINI TEST STATUS: ${e.response?.statusCode}');
      print('MINI TEST RESPONSE: ${e.response?.data}');
      print('MINI TEST QUERY: ${e.requestOptions.queryParameters}');

      throw Exception(
        e.response?.data?['detail']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Không thể tải mini test. Mã lỗi: ${e.response?.statusCode}',
      );
    }
  }

  Future<List<QuestionModel>> getFullTest() async {
    try {
      final response = await _dio.get('/questions/full-test');

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Response full-test không đúng format: $data');
      }

      if (data['questions'] is! List) {
        throw Exception('Response full-test thiếu questions: $data');
      }

      final list = data['questions'] as List;

      return list
          .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      print('FULL TEST URL: ${e.requestOptions.uri}');
      print('FULL TEST STATUS: ${e.response?.statusCode}');
      print('FULL TEST RESPONSE: ${e.response?.data}');

      throw Exception(
        e.response?.data?['detail']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Không thể tải full test. Mã lỗi: ${e.response?.statusCode}',
      );
    }
  }

  Future<List<QuestionModel>> getQuestions({
    int? part,
    bool randomMode = false,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/questions',
        queryParameters: {
          if (part != null) 'part': part,
          'random_mode': randomMode,
          'limit': limit,
        },
      );

      if (response.data is! List) {
        throw Exception(
          'Response questions không đúng format: ${response.data}',
        );
      }

      final list = response.data as List;
      return list
          .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      print('GET QUESTIONS URL: ${e.requestOptions.uri}');
      print('GET QUESTIONS STATUS: ${e.response?.statusCode}');
      print('GET QUESTIONS RESPONSE: ${e.response?.data}');
      print('GET QUESTIONS QUERY: ${e.requestOptions.queryParameters}');

      throw Exception(
        e.response?.data?['detail']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Không thể tải danh sách câu hỏi. Mã lỗi: ${e.response?.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> submit({
    required String testType,
    required List<Map<String, dynamic>> answers,
  }) async {
    if (answers.isEmpty) {
      throw Exception('Danh sách đáp án đang trống, không có dữ liệu để nộp.');
    }

    // Đã bỏ logic chặn nộp bài nếu có câu chưa làm để phù hợp thực tế.
    // Dữ liệu trống sẽ được gửi lên Backend xử lý là câu trả lời sai.

    try {
      final response = await _dio.post(
        '/questions/submit',
        data: {
          'test_type': testType,
          'answers': answers,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print('SUBMIT URL: ${e.requestOptions.uri}');
      print('SUBMIT STATUS: ${e.response?.statusCode}');
      print('SUBMIT RESPONSE: ${e.response?.data}');
      print('SUBMIT BODY: ${e.requestOptions.data}');

      throw Exception(
        e.response?.data?['detail']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Không thể nộp bài. Mã lỗi: ${e.response?.statusCode}',
      );
    }
  }

  Future<List<AttemptModel>> getAttempts() async {
    try {
      final response = await _dio.get('/questions/attempts');

      if (response.data is! List) {
        throw Exception(
          'Response attempts không đúng format: ${response.data}',
        );
      }

      final list = response.data as List;
      return list
          .map((e) => AttemptModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      print('ATTEMPTS URL: ${e.requestOptions.uri}');
      print('ATTEMPTS STATUS: ${e.response?.statusCode}');
      print('ATTEMPTS RESPONSE: ${e.response?.data}');

      throw Exception(
        e.response?.data?['detail']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Không thể lấy lịch sử làm bài. Mã lỗi: ${e.response?.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> getAttemptDetail(int attemptId) async {
    try {
      final response = await _dio.get('/questions/attempts/$attemptId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print('ATTEMPT DETAIL URL: ${e.requestOptions.uri}');
      print('ATTEMPT DETAIL STATUS: ${e.response?.statusCode}');
      print('ATTEMPT DETAIL RESPONSE: ${e.response?.data}');

      throw Exception(
        e.response?.data?['detail']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Không thể lấy chi tiết bài làm. Mã lỗi: ${e.response?.statusCode}',
      );
    }
  }

  Future<void> bookmarkQuestion(int questionId) async {
    try {
      await _dio.post('/questions/$questionId/bookmark');
    } on DioException catch (e) {
      print('BOOKMARK URL: ${e.requestOptions.uri}');
      print('BOOKMARK STATUS: ${e.response?.statusCode}');
      print('BOOKMARK RESPONSE: ${e.response?.data}');

      throw Exception(
        e.response?.data?['detail']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Không thể bookmark câu hỏi. Mã lỗi: ${e.response?.statusCode}',
      );
    }
  }

  Future<void> unbookmarkQuestion(int questionId) async {
    try {
      await _dio.delete('/questions/$questionId/bookmark');
    } on DioException catch (e) {
      print('UNBOOKMARK URL: ${e.requestOptions.uri}');
      print('UNBOOKMARK STATUS: ${e.response?.statusCode}');
      print('UNBOOKMARK RESPONSE: ${e.response?.data}');

      throw Exception(
        e.response?.data?['detail']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Không thể bỏ bookmark. Mã lỗi: ${e.response?.statusCode}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    try {
      final response = await _dio.get('/questions/bookmarks/me');

      if (response.data is! List) {
        throw Exception(
          'Response bookmarks không đúng format: ${response.data}',
        );
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('BOOKMARKS URL: ${e.requestOptions.uri}');
      print('BOOKMARKS STATUS: ${e.response?.statusCode}');
      print('BOOKMARKS RESPONSE: ${e.response?.data}');

      throw Exception(
        e.response?.data?['detail']?.toString() ??
            e.response?.data?['message']?.toString() ??
            'Không thể lấy bookmarks. Mã lỗi: ${e.response?.statusCode}',
      );
    }
  }
}