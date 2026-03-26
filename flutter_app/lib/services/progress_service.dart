import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService extends ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  int studiedWords = 0;
  int completedTests = 0;
  int currentStreak = 0;
  double overallProgress = 0.0;

  Future<void> loadProgress(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await _dio.get(
        '/progress/$userId',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data;
      studiedWords = data['studied_words'] ?? 0;
      completedTests = data['completed_tests'] ?? 0;
      currentStreak = data['current_streak'] ?? 0;
      overallProgress = (data['overall_progress'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('Load progress error: $e');
    }
  }

  Future<void> saveProgress(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      await _dio.post(
        '/progress/save',
        data: {
          'user_id': userId,
          'studied_words': studiedWords,
          'completed_tests': completedTests,
          'current_streak': currentStreak,
          'overall_progress': overallProgress,
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      debugPrint('Save progress error: $e');
    }
  }

  Future<void> saveStudyProgress(int userId) async {
    studiedWords += 1;
    overallProgress = (overallProgress + 0.01).clamp(0.0, 1.0);
    notifyListeners();
    await saveProgress(userId);
  }

  Future<void> saveTestCompletion(int userId) async {
    completedTests += 1;
    overallProgress = (overallProgress + 0.03).clamp(0.0, 1.0);
    notifyListeners();
    await saveProgress(userId);
  }

  void reset() {
    studiedWords = 0;
    completedTests = 0;
    currentStreak = 0;
    overallProgress = 0.0;
    notifyListeners();
  }
}