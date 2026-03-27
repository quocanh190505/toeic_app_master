import 'package:dio/dio.dart';

import 'api_client.dart';

class AdminService {
  final Dio _dio = ApiClient().dio;

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await _dio.get('/admin/users');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> updateUserRole({
    required int userId,
    required String role,
  }) async {
    await _dio.put(
      '/admin/users/$userId/role',
      queryParameters: {'role': role},
    );
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

  Future<List<Map<String, dynamic>>> getQuestions({int? part}) async {
    final response = await _dio.get(
      '/admin/questions',
      queryParameters: {
        if (part != null) 'part': part,
      },
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> createQuestion({
    required int part,
    required String content,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    String? explanation,
    String? audioPath,
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'part': part,
      'content': content,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'explanation': explanation ?? '',
      if (audioPath != null && audioPath.isNotEmpty)
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: audioPath.split('/').last,
        ),
      if (imagePath != null && imagePath.isNotEmpty)
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
    });

    await _dio.post('/admin/questions', data: formData);
  }

  Future<void> updateQuestion({
    required int questionId,
    required int part,
    required String content,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    String? explanation,
    String? audioPath,
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'part': part,
      'content': content,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'explanation': explanation ?? '',
      if (audioPath != null && audioPath.isNotEmpty)
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: audioPath.split('/').last,
        ),
      if (imagePath != null && imagePath.isNotEmpty)
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
    });

    await _dio.put('/admin/questions/$questionId', data: formData);
  }

  Future<void> deleteQuestion(int questionId) async {
    await _dio.delete('/admin/questions/$questionId');
  }

  Future<List<Map<String, dynamic>>> getAttempts({int? userId}) async {
    final response = await _dio.get(
      '/admin/attempts',
      queryParameters: {
        if (userId != null) 'user_id': userId,
      },
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}
