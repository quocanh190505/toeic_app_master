class QuestionModel {
  final int id;
  final int part;
  final String content;
  final Map<String, dynamic> options;
  final String? audioUrl;
  final String? imageUrl;

  QuestionModel({
    required this.id,
    required this.part,
    required this.content,
    required this.options,
    this.audioUrl,
    this.imageUrl,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id'].toString()) ?? 0,

      // Ép kiểu an toàn cho part tương tự như id
      part: json['part'] is int 
          ? json['part'] 
          : int.tryParse(json['part'].toString()) ?? 0,

      
      content: json['content']?.toString() ?? '',

      options: Map<String, dynamic>.from(json['options'] ?? {}),

      audioUrl: json['audio_url']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }
}