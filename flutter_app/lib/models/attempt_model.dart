class AttemptModel {
  final int id;
  final String testType;
  final int totalQuestions;
  final int correctCount;
  final int score;
  final String submittedAt;

  AttemptModel({
    required this.id,
    required this.testType,
    required this.totalQuestions,
    required this.correctCount,
    required this.score,
    required this.submittedAt,
  });

  factory AttemptModel.fromJson(Map<String, dynamic> json) {
    return AttemptModel(
      id: json['id'],
      testType: json['test_type'] ?? 'mini',
      totalQuestions: json['total_questions'] ?? 0,
      correctCount: json['correct_count'] ?? 0,
      score: json['score'] ?? 0,
      submittedAt: json['submitted_at'] ?? '',
    );
  }
}