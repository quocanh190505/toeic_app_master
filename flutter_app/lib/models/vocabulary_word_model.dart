class VocabularyWordModel {
  final int id;
  final String word;
  final String meaning;
  final String? example;
  final int? topicId; // Thêm topicId nếu cần dùng
  bool isStudied;     // CỰC KỲ QUAN TRỌNG: Để lưu trạng thái đã học

  VocabularyWordModel({
    required this.id,
    required this.word,
    required this.meaning,
    this.example,
    this.topicId,
    this.isStudied = false, // Mặc định là chưa học
  });

  factory VocabularyWordModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, [int fallback = 0]) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool toBool(dynamic value) {
      if (value is bool) return value;
      final normalized = value?.toString().trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }

    return VocabularyWordModel(
      id: toInt(json['id']),
      word: (json['word'] ?? '').toString(),
      meaning: (json['meaning'] ?? '').toString(),
      example: json['example']?.toString(),
      topicId: json['topic_id'] == null ? null : toInt(json['topic_id']),
      // Khớp chính xác với key "is_studied" từ Backend trả về
      isStudied: toBool(json['is_studied']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'example': example,
      'topic_id': topicId,
      'is_studied': isStudied,
    };
  }
}
