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
    int toInt(dynamic value, [int fallback = 0]) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return AttemptModel(
      id: toInt(json['id']),
      testType: (json['test_type'] ?? 'mini').toString(),
      totalQuestions: toInt(json['total_questions']),
      correctCount: toInt(json['correct_count']),
      score: toInt(json['score']),
      submittedAt: (json['submitted_at'] ?? '').toString(),
    );
  }
}
