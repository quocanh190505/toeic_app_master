class QuestionModel {
  final int id;
  final int part;
  final String content;
  final List<String> options;
  final String correctAnswer;
  final String? audioUrl;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.part,
    required this.content,
    required this.options,
    required this.correctAnswer,
    this.audioUrl,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      part: int.tryParse(json['part'].toString()) ?? 0,
      content: json['content']?.toString() ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      correctAnswer: json['correct_answer']?.toString() ??
          json['correctAnswer']?.toString() ??
          '',
      audioUrl: json['audio_url']?.toString() ??
          json['audioUrl']?.toString(),
      explanation: json['explanation']?.toString(),
    );
  }
}