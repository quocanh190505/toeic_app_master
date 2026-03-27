class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String uploadsBaseUrl = '$baseUrl/uploads';

  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String me = '$baseUrl/auth/me';
  static const String refresh = '$baseUrl/auth/refresh';
  static const String changePassword = '$baseUrl/auth/change-password';

  static const String questions = '$baseUrl/questions';
  static const String miniTest = '$baseUrl/questions/mini-test';
  static const String fullTest = '$baseUrl/questions/full-test';
  static const String submit = '$baseUrl/questions/submit';
  static const String attempts = '$baseUrl/questions/attempts';

  static const String progress = '$baseUrl/progress/me';

  static const String vocabulary = '$baseUrl/vocabulary';
  static const String studiedWords = '$baseUrl/vocabulary/studied/me';

  static const String dashboard = '$baseUrl/stats/dashboard/me';
  static const String leaderboard = '$baseUrl/stats/leaderboard';
  static const String partStats = '$baseUrl/stats/parts/me';

  static String questionBookmark(int questionId) =>
      '$baseUrl/questions/$questionId/bookmark';

  static String attemptDetail(int attemptId) =>
      '$baseUrl/questions/attempts/$attemptId';

  static String studyWord(int wordId) =>
      '$baseUrl/vocabulary/$wordId/study';

  static String uploadUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    return '$baseUrl$relativePath';
  }
}
