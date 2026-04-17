class ProgressModel {
  final int userId;
  final int studiedWords;
  final int completedTests;
  final int currentStreak;
  final double overallProgress;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final int highestScore;
  final double averageScore;

  ProgressModel({
    required this.userId,
    required this.studiedWords,
    required this.completedTests,
    required this.currentStreak,
    required this.overallProgress,
    required this.totalQuestionsAnswered,
    required this.totalCorrectAnswers,
    required this.highestScore,
    required this.averageScore,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, [int fallback = 0]) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    double toDouble(dynamic value, [double fallback = 0]) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return ProgressModel(
      userId: toInt(json['user_id']),
      studiedWords: toInt(json['studied_words']),
      completedTests: toInt(json['completed_tests']),
      currentStreak: toInt(json['current_streak']),
      overallProgress: toDouble(json['overall_progress']),
      totalQuestionsAnswered: toInt(json['total_questions_answered']),
      totalCorrectAnswers: toInt(json['total_correct_answers']),
      highestScore: toInt(json['highest_score']),
      averageScore: toDouble(json['average_score']),
    );
  }
}
