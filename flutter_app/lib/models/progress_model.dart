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
    return ProgressModel(
      userId: json['user_id'],
      studiedWords: json['studied_words'] ?? 0,
      completedTests: json['completed_tests'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      overallProgress: (json['overall_progress'] ?? 0).toDouble(),
      totalQuestionsAnswered: json['total_questions_answered'] ?? 0,
      totalCorrectAnswers: json['total_correct_answers'] ?? 0,
      highestScore: json['highest_score'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
    );
  }
}