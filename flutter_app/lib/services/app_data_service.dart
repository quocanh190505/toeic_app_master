import 'package:dio/dio.dart';

import '../../models/progress_model.dart';
import '../../models/vocabulary_word_model.dart';
import 'api_client.dart';

class AppDataService {
  final Dio _dio = ApiClient().dio;

  Future<ProgressModel> getProgress() async {
    final response = await _dio.get('/progress/me');
    return ProgressModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _dio.get('/stats/dashboard/me');
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await _dio.get('/stats/leaderboard');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getPartStats() async {
    final response = await _dio.get('/stats/parts/me');
    return Map<String, dynamic>.from(response.data);
  }

  // Thêm tham số topicId vào đây
  Future<List<VocabularyWordModel>> getVocabulary({int? topicId}) async {
    // Nếu có truyền topicId thì thêm vào queryParameters
    final response = await _dio.get(
      '/vocabulary',
      queryParameters: topicId != null ? {'topic_id': topicId} : null,
    );
    final list = response.data as List;
    return list.map((e) => VocabularyWordModel.fromJson(e)).toList();
  }

  Future<void> studyWord(int wordId) async {
    await _dio.post('/vocabulary/$wordId/study');
  }

  Future<List<Map<String, dynamic>>> getStudiedWords() async {
    final response = await _dio.get('/vocabulary/studied/me');
    return List<Map<String, dynamic>>.from(response.data);
  }
}