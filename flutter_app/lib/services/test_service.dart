import 'package:dio/dio.dart';

import '../../models/attempt_model.dart';
import '../../models/question_model.dart';
import 'api_client.dart';

class TestService {
  final Dio _dio = ApiClient().dio;

  static const List<int> validMiniTestParts = [1, 2, 3, 4, 5, 6, 7];

  String _translateErrorMessage(String message) {
    const translations = {
      'Full test chỉ dành cho thành viên Premium.':
          'Full test chỉ dành cho thành viên Premium.',
      'Kho đề đã phát hành chỉ dành cho thành viên Premium.':
          'Kho đề đã phát hành chỉ dành cho thành viên Premium.',
      'Published test not found': 'Không tìm thấy đề đã phát hành.',
      'Attempt not found': 'Không tìm thấy bài làm.',
      'Question not found': 'Không tìm thấy câu hỏi.',
      'Answers cannot be empty': 'Danh sách đáp án không được để trống.',
      'Invalid test_type': 'Loại đề không hợp lệ.',
      'Duplicate question_id in answers':
          'Danh sách đáp án đang bị trùng câu hỏi.',
      'Some question_ids are invalid': 'Có câu hỏi không hợp lệ trong danh sách.',
      'Already bookmarked': 'Câu hỏi này đã được lưu trước đó.',
      'Bookmarked successfully': 'Đã lưu câu hỏi thành công.',
      'Bookmark removed successfully': 'Đã bỏ lưu câu hỏi thành công.',
      'Invalid part for mini test': 'Part không hợp lệ cho mini test.',
    };

    return translations[message.trim()] ?? message.trim();
  }

  String _extractDioMessage(DioException error, String fallback) {
    final data = error.response?.data;

    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return _translateErrorMessage(detail);
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
        return fallback;
    }
  }

  Map<String, dynamic> _asStringMap(dynamic value, String context) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    throw Exception('$context không đúng định dạng dữ liệu.');
  }

  List<QuestionModel> _parseQuestionList(dynamic raw, String context) {
    if (raw is! List) {
      throw Exception('$context không phải danh sách câu hỏi.');
    }

    return raw.asMap().entries.map((entry) {
      final itemMap = _asStringMap(
        entry.value,
        '$context tại vị trí ${entry.key + 1}',
      );
      return QuestionModel.fromJson(itemMap);
    }).toList();
  }

  void _validateMiniTestPart(int part) {
    if (!validMiniTestParts.contains(part)) {
      throw Exception(
        'Part không hợp lệ. Chỉ chấp nhận: ${validMiniTestParts.join(', ')}.',
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
        throw Exception('Dữ liệu mini test trả về không hợp lệ.');
      }

      if (data['questions'] is! List) {
        throw Exception('Máy chủ chưa trả về danh sách câu hỏi mini test.');
      }

      return _parseQuestionList(data['questions'], 'Dữ liệu mini test');
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể tải mini test lúc này.'),
      );
    }
  }

  Future<List<QuestionModel>> getFullTest() async {
    try {
      final response = await _dio.get('/questions/full-test');

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Dữ liệu full test trả về không hợp lệ.');
      }

      if (data['questions'] is! List) {
        throw Exception('Máy chủ chưa trả về danh sách câu hỏi full test.');
      }

      return _parseQuestionList(data['questions'], 'Dữ liệu full test');
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể tải full test lúc này.'),
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
        throw Exception('Dữ liệu danh sách câu hỏi trả về không hợp lệ.');
      }

      return _parseQuestionList(response.data, 'Dữ liệu danh sách câu hỏi');
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể tải danh sách câu hỏi.'),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPublishedTests() async {
    try {
      final response = await _dio.get('/questions/published-tests');
      if (response.data is! List) {
        throw Exception('Dữ liệu kho đề trả về không hợp lệ.');
      }
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể tải kho đề đã phát hành.'),
      );
    }
  }

  Future<Map<String, dynamic>> getPublishedTestDetail(int publishedTestId) async {
    try {
      final response =
          await _dio.get('/questions/published-tests/$publishedTestId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể tải chi tiết đề đã phát hành.'),
      );
    }
  }

  Future<Map<String, dynamic>> submit({
    required String testType,
    required List<Map<String, dynamic>> answers,
  }) async {
    if (answers.isEmpty) {
      throw Exception('Danh sách đáp án đang trống, chưa thể nộp bài.');
    }

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
      throw Exception(
        _extractDioMessage(e, 'Không thể nộp bài lúc này.'),
      );
    }
  }

  Future<List<AttemptModel>> getAttempts() async {
    try {
      final response = await _dio.get('/questions/attempts');

      if (response.data is! List) {
        throw Exception('Dữ liệu lịch sử làm bài trả về không hợp lệ.');
      }

      final list = response.data as List;
      return list
          .map((e) => AttemptModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể tải lịch sử làm bài.'),
      );
    }
  }

  Future<Map<String, dynamic>> getAttemptDetail(int attemptId) async {
    try {
      final response = await _dio.get('/questions/attempts/$attemptId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể tải chi tiết bài làm.'),
      );
    }
  }

  Future<void> bookmarkQuestion(int questionId) async {
    try {
      await _dio.post('/questions/$questionId/bookmark');
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể lưu câu hỏi này.'),
      );
    }
  }

  Future<void> unbookmarkQuestion(int questionId) async {
    try {
      await _dio.delete('/questions/$questionId/bookmark');
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể bỏ lưu câu hỏi này.'),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    try {
      final response = await _dio.get('/questions/bookmarks/me');

      if (response.data is! List) {
        throw Exception('Dữ liệu câu hỏi đã lưu trả về không hợp lệ.');
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _extractDioMessage(e, 'Không thể tải danh sách câu hỏi đã lưu.'),
      );
    }
  }
}
