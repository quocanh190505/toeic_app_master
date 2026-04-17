import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class CreateQuestionScreen extends StatefulWidget {
  final Map<String, dynamic>? question;

  const CreateQuestionScreen({super.key, this.question});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final AdminService service = AdminService();

  final contentCtrl = TextEditingController();
  final optionACtrl = TextEditingController();
  final optionBCtrl = TextEditingController();
  final optionCCtrl = TextEditingController();
  final optionDCtrl = TextEditingController();
  final explanationCtrl = TextEditingController();
  final groupKeyCtrl = TextEditingController();
  final questionOrderCtrl = TextEditingController(text: '1');
  final instructionsCtrl = TextEditingController();
  final sharedContentCtrl = TextEditingController();
  final sharedImageUrlCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();

  int part = 1;
  String section = 'listening';
  String difficulty = 'medium';
  String correctAnswer = 'A';
  String? sharedAudioPath;
  String? sharedImagePath;
  String? audioPath;
  String? imagePath;
  bool loading = false;
  String? error;

  bool get _isEdit => widget.question != null;

  int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String? get _existingSharedAudioUrl =>
      widget.question?['shared_audio_url']?.toString();
  String? get _existingSharedImageUrl =>
      widget.question?['shared_image_url']?.toString();
  String? get _existingAudioUrl => widget.question?['audio_url']?.toString();
  String? get _existingImageUrl => widget.question?['image_url']?.toString();

  @override
  void initState() {
    super.initState();
    final question = widget.question;
    if (question != null) {
      part = _toInt(question['part'], 1);
      section =
          question['section']?.toString() ?? (part <= 4 ? 'listening' : 'reading');
      difficulty = question['difficulty']?.toString() ?? 'medium';
      groupKeyCtrl.text = question['group_key']?.toString() ?? '';
      questionOrderCtrl.text = question['question_order']?.toString() ?? '1';
      instructionsCtrl.text = question['instructions']?.toString() ?? '';
      sharedContentCtrl.text = question['shared_content']?.toString() ?? '';
      sharedImageUrlCtrl.text = question['shared_image_url']?.toString() ?? '';
      imageUrlCtrl.text = question['image_url']?.toString() ?? '';
      contentCtrl.text = question['content']?.toString() ?? '';
      optionACtrl.text = question['option_a']?.toString() ?? '';
      optionBCtrl.text = question['option_b']?.toString() ?? '';
      optionCCtrl.text = question['option_c']?.toString() ?? '';
      optionDCtrl.text = question['option_d']?.toString() ?? '';
      correctAnswer = question['correct_answer']?.toString() ?? 'A';
      explanationCtrl.text = question['explanation']?.toString() ?? '';
    }
  }

  Future<void> _pickAudio({required bool shared}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'm4a'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    setState(() {
      if (shared) {
        sharedAudioPath = path;
      } else {
        audioPath = path;
      }
    });
  }

  Future<void> _pickImage({required bool shared}) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null) return;
    setState(() {
      if (shared) {
        sharedImagePath = path;
      } else {
        imagePath = path;
      }
    });
  }

  Future<void> submit() async {
    if (contentCtrl.text.trim().isEmpty ||
        optionACtrl.text.trim().isEmpty ||
        optionBCtrl.text.trim().isEmpty ||
        optionCCtrl.text.trim().isEmpty ||
        optionDCtrl.text.trim().isEmpty) {
      setState(() {
        error = 'Vui lòng nhập đầy đủ nội dung câu hỏi và 4 đáp án.';
      });
      return;
    }

    final questionOrder = int.tryParse(questionOrderCtrl.text.trim());
    if (questionOrder == null || questionOrder < 1) {
      setState(() {
        error = 'Thứ tự câu trong nhóm phải là số nguyên lớn hơn hoặc bằng 1.';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      if (_isEdit) {
        await service.updateQuestion(
          questionId: _toInt(widget.question?['id']),
          part: part,
          section: section,
          difficulty: difficulty,
          groupKey: groupKeyCtrl.text.trim(),
          questionOrder: questionOrder,
          instructions: instructionsCtrl.text.trim(),
          sharedContent: sharedContentCtrl.text.trim(),
          sharedImageUrl: sharedImageUrlCtrl.text.trim(),
          imageUrl: imageUrlCtrl.text.trim(),
          content: contentCtrl.text.trim(),
          optionA: optionACtrl.text.trim(),
          optionB: optionBCtrl.text.trim(),
          optionC: optionCCtrl.text.trim(),
          optionD: optionDCtrl.text.trim(),
          correctAnswer: correctAnswer,
          explanation: explanationCtrl.text.trim(),
          sharedAudioPath: sharedAudioPath,
          sharedImagePath: sharedImagePath,
          audioPath: audioPath,
          imagePath: imagePath,
        );
      } else {
        await service.createQuestion(
          part: part,
          section: section,
          difficulty: difficulty,
          groupKey: groupKeyCtrl.text.trim(),
          questionOrder: questionOrder,
          instructions: instructionsCtrl.text.trim(),
          sharedContent: sharedContentCtrl.text.trim(),
          sharedImageUrl: sharedImageUrlCtrl.text.trim(),
          imageUrl: imageUrlCtrl.text.trim(),
          content: contentCtrl.text.trim(),
          optionA: optionACtrl.text.trim(),
          optionB: optionBCtrl.text.trim(),
          optionC: optionCCtrl.text.trim(),
          optionD: optionDCtrl.text.trim(),
          correctAnswer: correctAnswer,
          explanation: explanationCtrl.text.trim(),
          sharedAudioPath: sharedAudioPath,
          sharedImagePath: sharedImagePath,
          audioPath: audioPath,
          imagePath: imagePath,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Cập nhật câu hỏi thành công.' : 'Tạo câu hỏi thành công.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    contentCtrl.dispose();
    optionACtrl.dispose();
    optionBCtrl.dispose();
    optionCCtrl.dispose();
    optionDCtrl.dispose();
    explanationCtrl.dispose();
    groupKeyCtrl.dispose();
    questionOrderCtrl.dispose();
    instructionsCtrl.dispose();
    sharedContentCtrl.dispose();
    sharedImageUrlCtrl.dispose();
    imageUrlCtrl.dispose();
    super.dispose();
  }

  Widget _uploadTile({
    required IconData icon,
    required String title,
    required String? path,
    required String? existingUrl,
    required VoidCallback onPick,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          path != null
              ? path.split('/').last
              : (existingUrl != null && existingUrl.isNotEmpty)
                  ? existingUrl.split('/').last
                  : 'Chưa chọn file',
        ),
        trailing: TextButton(onPressed: onPick, child: const Text('Chọn file')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Chỉnh sửa câu hỏi' : 'Thêm câu hỏi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue: part,
              decoration: const InputDecoration(labelText: 'Part'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Part 1')),
                DropdownMenuItem(value: 2, child: Text('Part 2')),
                DropdownMenuItem(value: 3, child: Text('Part 3')),
                DropdownMenuItem(value: 4, child: Text('Part 4')),
                DropdownMenuItem(value: 5, child: Text('Part 5')),
                DropdownMenuItem(value: 6, child: Text('Part 6')),
                DropdownMenuItem(value: 7, child: Text('Part 7')),
              ],
              onChanged: (v) {
                setState(() {
                  part = v ?? 1;
                  section = part <= 4 ? 'listening' : 'reading';
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: section,
              decoration: const InputDecoration(labelText: 'Section'),
              items: const [
                DropdownMenuItem(value: 'listening', child: Text('Listening')),
                DropdownMenuItem(value: 'reading', child: Text('Reading')),
              ],
              onChanged: (v) => setState(() => section = v ?? section),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: difficulty,
              decoration: const InputDecoration(labelText: 'Mức độ'),
              items: const [
                DropdownMenuItem(value: 'easy', child: Text('Dễ')),
                DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
                DropdownMenuItem(value: 'hard', child: Text('Khó')),
              ],
              onChanged: (v) => setState(() => difficulty = v ?? 'medium'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: groupKeyCtrl,
              decoration: const InputDecoration(labelText: 'Mã nhóm câu hỏi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: questionOrderCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Thứ tự câu trong nhóm'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instructionsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Hướng dẫn chung'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sharedContentCtrl,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Nội dung dùng chung'),
            ),
            const SizedBox(height: 12),
            _uploadTile(
              icon: Icons.library_music,
              title: 'Audio dùng chung',
              path: sharedAudioPath,
              existingUrl: _existingSharedAudioUrl,
              onPick: () => _pickAudio(shared: true),
            ),
            const SizedBox(height: 12),
            _uploadTile(
              icon: Icons.photo_library_outlined,
              title: 'Hình ảnh dùng chung',
              path: sharedImagePath,
              existingUrl: _existingSharedImageUrl,
              onPick: () => _pickImage(shared: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sharedImageUrlCtrl,
              decoration: const InputDecoration(labelText: 'Link hình ảnh nhóm'),
            ),
            if (_existingSharedImageUrl != null &&
                _existingSharedImageUrl!.isNotEmpty &&
                sharedImagePath == null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  ApiConstants.uploadUrl(_existingSharedImageUrl),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 180,
                    color: const Color(0xFFF1F5F9),
                    alignment: Alignment.center,
                    child: const Text('Không tải được ảnh nhóm hiện tại'),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Nội dung câu hỏi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: optionACtrl,
              decoration: const InputDecoration(labelText: 'Đáp án A'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: optionBCtrl,
              decoration: const InputDecoration(labelText: 'Đáp án B'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: optionCCtrl,
              decoration: const InputDecoration(labelText: 'Đáp án C'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: optionDCtrl,
              decoration: const InputDecoration(labelText: 'Đáp án D'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: correctAnswer,
              decoration: const InputDecoration(labelText: 'Đáp án đúng'),
              items: const [
                DropdownMenuItem(value: 'A', child: Text('A')),
                DropdownMenuItem(value: 'B', child: Text('B')),
                DropdownMenuItem(value: 'C', child: Text('C')),
                DropdownMenuItem(value: 'D', child: Text('D')),
              ],
              onChanged: (v) => setState(() => correctAnswer = v ?? 'A'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: explanationCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Giải thích'),
            ),
            const SizedBox(height: 12),
            _uploadTile(
              icon: Icons.audiotrack,
              title: 'Audio riêng của câu',
              path: audioPath,
              existingUrl: _existingAudioUrl,
              onPick: () => _pickAudio(shared: false),
            ),
            const SizedBox(height: 12),
            _uploadTile(
              icon: Icons.image,
              title: 'Hình ảnh riêng của câu',
              path: imagePath,
              existingUrl: _existingImageUrl,
              onPick: () => _pickImage(shared: false),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: imageUrlCtrl,
              decoration: const InputDecoration(labelText: 'Link hình ảnh riêng'),
            ),
            if (_existingImageUrl != null &&
                _existingImageUrl!.isNotEmpty &&
                imagePath == null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  ApiConstants.uploadUrl(_existingImageUrl),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 180,
                    color: const Color(0xFFF1F5F9),
                    alignment: Alignment.center,
                    child: const Text('Không tải được ảnh hiện tại'),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (error != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  error!,
                  style: const TextStyle(color: AppTheme.danger),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEdit ? 'Lưu thay đổi' : 'Tạo câu hỏi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
