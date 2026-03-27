class VocabularyWordModel {
  final int id;
  final String word;
  final String meaning;
  final String? example;

  VocabularyWordModel({
    required this.id,
    required this.word,
    required this.meaning,
    this.example,
  });

  factory VocabularyWordModel.fromJson(Map<String, dynamic> json) {
    return VocabularyWordModel(
      id: json['id'],
      word: json['word'],
      meaning: json['meaning'],
      example: json['example'],
    );
  }
}