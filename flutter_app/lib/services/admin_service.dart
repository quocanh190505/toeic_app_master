import 'package:dio/dio.dart';

import 'api_client.dart';

class AdminService {
  final Dio _dio = ApiClient().dio;

  String _extractDioMessage(DioException error, String fallback) {
    final data = error.response?.data;

    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
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

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await _dio.get('/admin/users');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> updateUserRole({
    required int userId,
    required String role,
  }) async {
    await _dio.put('/admin/users/$userId/role', queryParameters: {'role': role});
  }

  Future<void> resetUserPassword({
    required int userId,
    required String newPassword,
  }) async {
    await _dio.post(
      '/admin/users/$userId/reset-password',
      queryParameters: {'new_password': newPassword},
    );
  }

  Future<void> deleteUser(int userId) async {
    await _dio.delete('/admin/users/$userId');
  }

  Future<List<Map<String, dynamic>>> getQuestions({
    int? part,
    String? approvalStatus,
  }) async {
    final response = await _dio.get(
      '/admin/questions',
      queryParameters: {
        if (part != null) 'part': part,
        if (approvalStatus != null && approvalStatus.isNotEmpty)
          'approval_status': approvalStatus,
      },
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> createQuestion({
    required int part,
    String? section,
    String difficulty = 'medium',
    String? groupKey,
    int questionOrder = 1,
    String? instructions,
    String? sharedContent,
    required String content,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    String? explanation,
    String? sharedImageUrl,
    String? imageUrl,
    String? sharedAudioPath,
    String? sharedImagePath,
    String? audioPath,
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'part': part,
      'section': section ?? (part <= 4 ? 'listening' : 'reading'),
      'difficulty': difficulty,
      'group_key': groupKey ?? '',
      'question_order': questionOrder,
      'instructions': instructions ?? '',
      'shared_content': sharedContent ?? '',
      'content': content,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'explanation': explanation ?? '',
      'shared_image_url': sharedImageUrl ?? '',
      'image_url': imageUrl ?? '',
      if (sharedAudioPath != null && sharedAudioPath.isNotEmpty)
        'shared_audio': await MultipartFile.fromFile(sharedAudioPath),
      if (sharedImagePath != null && sharedImagePath.isNotEmpty)
        'shared_image': await MultipartFile.fromFile(sharedImagePath),
      if (audioPath != null && audioPath.isNotEmpty)
        'audio': await MultipartFile.fromFile(audioPath),
      if (imagePath != null && imagePath.isNotEmpty)
        'image': await MultipartFile.fromFile(imagePath),
    });

    await _dio.post('/admin/questions', data: formData);
  }

  Future<void> updateQuestion({
    required int questionId,
    required int part,
    String? section,
    String difficulty = 'medium',
    String? groupKey,
    int questionOrder = 1,
    String? instructions,
    String? sharedContent,
    required String content,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    String? explanation,
    String? sharedImageUrl,
    String? imageUrl,
    String? sharedAudioPath,
    String? sharedImagePath,
    String? audioPath,
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'part': part,
      'section': section ?? (part <= 4 ? 'listening' : 'reading'),
      'difficulty': difficulty,
      'group_key': groupKey ?? '',
      'question_order': questionOrder,
      'instructions': instructions ?? '',
      'shared_content': sharedContent ?? '',
      'content': content,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'explanation': explanation ?? '',
      'shared_image_url': sharedImageUrl ?? '',
      'image_url': imageUrl ?? '',
      if (sharedAudioPath != null && sharedAudioPath.isNotEmpty)
        'shared_audio': await MultipartFile.fromFile(sharedAudioPath),
      if (sharedImagePath != null && sharedImagePath.isNotEmpty)
        'shared_image': await MultipartFile.fromFile(sharedImagePath),
      if (audioPath != null && audioPath.isNotEmpty)
        'audio': await MultipartFile.fromFile(audioPath),
      if (imagePath != null && imagePath.isNotEmpty)
        'image': await MultipartFile.fromFile(imagePath),
    });

    await _dio.put('/admin/questions/$questionId', data: formData);
  }

  Future<void> deleteQuestion(int questionId) async {
    await _dio.delete('/admin/questions/$questionId');
  }

  Future<void> updateQuestionApproval({
    required int questionId,
    required String approvalStatus,
    String? reviewNote,
  }) async {
    await _dio.put(
      '/questions/$questionId/approval',
      data: {
        'approval_status': approvalStatus,
        'review_note': reviewNote,
      },
    );
  }

  Future<Map<String, dynamic>> generateTest({
    required String testType,
    int? part,
    List<int> avoidQuestionIds = const [],
  }) async {
    final response = await _dio.post(
      '/questions/generate',
      data: {
        'test_type': testType,
        if (part != null) 'part': part,
        'avoid_question_ids': avoidQuestionIds,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> createPublishedTest({
    required String title,
    String? description,
    required String testType,
    int? part,
    required List<int> questionIds,
  }) async {
    try {
      final response = await _dio.post(
        '/admin/published-tests',
        data: {
          'title': title,
          'description': description,
          'test_type': testType,
          'part': part,
          'question_ids': questionIds,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e, 'Không thể đưa đề vào kho đề học sinh.'));
    }
  }

  Future<List<Map<String, dynamic>>> getPublishedTests() async {
    final response = await _dio.get('/admin/published-tests');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getPublishedTestDetail(int publishedTestId) async {
    final response = await _dio.get('/admin/published-tests/$publishedTestId');
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getAttempts({int? userId}) async {
    final response = await _dio.get(
      '/admin/attempts',
      queryParameters: {if (userId != null) 'user_id': userId},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getAttemptDetail(int attemptId) async {
    final response = await _dio.get('/admin/attempts/$attemptId');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> importQuestionsDocument(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/admin/questions/import-document', data: formData);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e, 'Không thể nộp file Word/PDF.'));
    }
  }

  Future<Map<String, dynamic>> importQuestionsJson(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/admin/questions/import-json', data: formData);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e, 'Không thể nộp file JSON.'));
    }
  }

  Future<Map<String, dynamic>> previewQuestionsJson(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/admin/questions/preview-json', data: formData);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e, 'Không thể xem trước file JSON.'));
    }
  }

  Future<Map<String, dynamic>> previewQuestionsDocument(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/admin/questions/preview-document', data: formData);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e, 'Không thể xem trước file Word/PDF.'));
    }
  }

  Future<List<Map<String, dynamic>>> getPremiumPaymentRequests({String? status}) async {
    final response = await _dio.get(
      '/admin/premium-payment-requests',
      queryParameters: {if (status != null && status.isNotEmpty) 'status': status},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> reviewPremiumPaymentRequest({
    required int requestId,
    required String status,
    String? reviewNote,
  }) async {
    try {
      final response = await _dio.put(
        '/admin/premium-payment-requests/$requestId',
        data: {
          'status': status,
          'review_note': reviewNote,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e, 'Không thể cập nhật yêu cầu thanh toán.'));
    }
  }
}
