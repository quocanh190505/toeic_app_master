class QuestionModel {
  final int id;
  final int part;
  final String? section;
  final String? groupKey;
  final int questionOrder;
  final String? instructions;
  final String? sharedContent;
  final String? sharedAudioUrl;
  final String? sharedImageUrl;
  final String content;
  final Map<String, dynamic> options;
  final String? audioUrl;
  final String? imageUrl;

  QuestionModel({
    required this.id,
    required this.part,
    this.section,
    this.groupKey,
    this.questionOrder = 1,
    this.instructions,
    this.sharedContent,
    this.sharedAudioUrl,
    this.sharedImageUrl,
    required this.content,
    required this.options,
    this.audioUrl,
    this.imageUrl,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final normalizedJson = json.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    final optionsRaw = normalizedJson['options'];
    final optionsMap = optionsRaw is Map
        ? optionsRaw.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    return QuestionModel(
      id: normalizedJson['id'] is int
          ? normalizedJson['id']
          : int.tryParse(normalizedJson['id']?.toString() ?? '') ?? 0,
      part: normalizedJson['part'] is int
          ? normalizedJson['part']
          : int.tryParse(normalizedJson['part']?.toString() ?? '') ?? 0,
      section: normalizedJson['section']?.toString(),
      groupKey: normalizedJson['group_key']?.toString(),
      questionOrder: normalizedJson['question_order'] is int
          ? normalizedJson['question_order']
          : int.tryParse(normalizedJson['question_order']?.toString() ?? '') ??
              1,
      instructions: normalizedJson['instructions']?.toString(),
      sharedContent: normalizedJson['shared_content']?.toString(),
      sharedAudioUrl: normalizedJson['shared_audio_url']?.toString(),
      sharedImageUrl: normalizedJson['shared_image_url']?.toString(),
      content: normalizedJson['content']?.toString() ?? '',
      options: optionsMap,
      audioUrl: normalizedJson['audio_url']?.toString(),
      imageUrl: normalizedJson['image_url']?.toString(),
    );
  }
}
