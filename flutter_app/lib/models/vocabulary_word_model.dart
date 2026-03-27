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
    return VocabularyWordModel(
      id: json['id'],
      word: json['word'],
      meaning: json['meaning'],
      example: json['example'],
      topicId: json['topic_id'],
      // Khớp chính xác với key "is_studied" từ Backend trả về
      isStudied: json['is_studied'] ?? false, 
    );
  }

  // Thêm hàm toJson nếu sau này bạn cần gửi ngược dữ liệu lên
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