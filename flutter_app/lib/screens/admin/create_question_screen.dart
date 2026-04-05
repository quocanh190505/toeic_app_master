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
  String correctAnswer = 'A';
  String? sharedAudioPath;
  String? sharedImagePath;
  String? audioPath;
  String? imagePath;
  bool loading = false;
  String? error;

  bool get _isEdit => widget.question != null;
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
      part = question['part'] ?? 1;
      section = question['section']?.toString() ??
          (part <= 4 ? 'listening' : 'reading');
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
    } else {
      section = part <= 4 ? 'listening' : 'reading';
    }
  }

  Future<void> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'm4a'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        audioPath = result.files.single.path!;
      });
    }
  }

  Future<void> pickSharedAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'm4a'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        sharedAudioPath = result.files.single.path!;
      });
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        imagePath = result.files.single.path!;
      });
    }
  }

  Future<void> pickSharedImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        sharedImagePath = result.files.single.path!;
      });
    }
  }

  Future<void> submit() async {
    if (contentCtrl.text.trim().isEmpty ||
        optionACtrl.text.trim().isEmpty ||
        optionBCtrl.text.trim().isEmpty ||
        optionCCtrl.text.trim().isEmpty ||
        optionDCtrl.text.trim().isEmpty) {
      setState(() {
        error = 'Vui lòng nhập đầy đủ nội dung câu hỏi và 4 đáp án';
      });
      return;
    }

    final parsedQuestionOrder = int.tryParse(questionOrderCtrl.text.trim());
    if (parsedQuestionOrder == null || parsedQuestionOrder < 1) {
      setState(() {
        error = 'Thứ tự câu trong nhóm phải là số nguyên lớn hơn hoặc bằng 1';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final questionOrder = parsedQuestionOrder;

      if (_isEdit) {
        await service.updateQuestion(
          questionId: widget.question!['id'] as int,
          part: part,
          section: section,
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
            _isEdit ? 'Cập nhật câu hỏi thành công' : 'Tạo câu hỏi thành công',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
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
                DropdownMenuItem(
                  value: 'listening',
                  child: Text('Listening'),
                ),
                DropdownMenuItem(
                  value: 'reading',
                  child: Text('Reading'),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  section = v ?? (part <= 4 ? 'listening' : 'reading');
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: groupKeyCtrl,
              decoration: const InputDecoration(
                labelText: 'Mã nhóm câu hỏi',
                helperText:
                    'Các câu cùng đoạn/audio dùng chung một mã nhóm, ví dụ P4_SET_01',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: questionOrderCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Thứ tự câu trong nhóm',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instructionsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Hướng dẫn chung cho nhóm',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sharedContentCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Đoạn văn / nội dung dùng chung',
                helperText:
                    'Dùng cho Part 6, 7 hoặc transcript/mô tả chung của Part 3, 4',
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.library_music),
                title: const Text('Chọn audio dùng chung cho nhóm'),
                subtitle: Text(
                  sharedAudioPath != null
                      ? sharedAudioPath!.split('/').last
                      : (_existingSharedAudioUrl != null &&
                              _existingSharedAudioUrl!.isNotEmpty)
                          ? 'Đang có audio nhóm: ${_existingSharedAudioUrl!.split('/').last}'
                          : 'Chưa chọn file',
                ),
                trailing: TextButton(
                  onPressed: pickSharedAudio,
                  child: const Text('FilePicker'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_existingSharedAudioUrl != null &&
                _existingSharedAudioUrl!.isNotEmpty &&
                sharedAudioPath == null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Audio nhóm hiện tại: ${ApiConstants.uploadUrl(_existingSharedAudioUrl)}',
                  style: const TextStyle(
                    color: AppTheme.subText,
                    fontSize: 12,
                  ),
                ),
              ),
            if (_existingSharedAudioUrl != null &&
                _existingSharedAudioUrl!.isNotEmpty &&
                sharedAudioPath == null)
              const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Chon hinh dung chung cho nhom'),
                subtitle: Text(
                  sharedImagePath != null
                      ? sharedImagePath!.split('/').last
                      : (_existingSharedImageUrl != null &&
                              _existingSharedImageUrl!.isNotEmpty)
                          ? 'Dang co anh nhom: ${_existingSharedImageUrl!.split('/').last}'
                          : 'Chua chon file',
                ),
                trailing: TextButton(
                  onPressed: pickSharedImage,
                  child: const Text('FilePicker'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sharedImageUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Link / duong dan anh nhom',
                helperText:
                    'Co the nhap URL day du hoac duong dan nhu /uploads/images/example.png',
              ),
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
              const SizedBox(height: 12),
            ],
            TextField(
              controller: contentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nội dung câu hỏi',
              ),
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
              onChanged: (v) {
                setState(() {
                  correctAnswer = v ?? 'A';
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: explanationCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Giải thích',
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.audiotrack),
                title: const Text('Chọn file audio'),
                subtitle: Text(
                  audioPath != null
                      ? audioPath!.split('/').last
                      : (_existingAudioUrl != null &&
                              _existingAudioUrl!.isNotEmpty)
                          ? 'Đang có audio: ${_existingAudioUrl!.split('/').last}'
                          : 'Chưa chọn file',
                ),
                trailing: TextButton(
                  onPressed: pickAudio,
                  child: const Text('FilePicker'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_existingAudioUrl != null &&
                _existingAudioUrl!.isNotEmpty &&
                audioPath == null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Audio hiện tại: ${ApiConstants.uploadUrl(_existingAudioUrl)}',
                  style: const TextStyle(
                    color: AppTheme.subText,
                    fontSize: 12,
                  ),
                ),
              ),
            if (_existingAudioUrl != null &&
                _existingAudioUrl!.isNotEmpty &&
                audioPath == null)
              const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Chon hinh anh'),
                subtitle: Text(
                  imagePath != null
                      ? imagePath!.split('/').last
                      : (_existingImageUrl != null &&
                              _existingImageUrl!.isNotEmpty)
                          ? 'Dang co anh: ${_existingImageUrl!.split('/').last}'
                          : 'Chua chon file',
                ),
                trailing: TextButton(
                  onPressed: pickImage,
                  child: const Text('FilePicker'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: imageUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Link / duong dan anh',
                helperText:
                    'Dung cho Part 1 neu may ao khong chon duoc anh tu gallery',
              ),
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
                  style: const TextStyle(color: Colors.red),
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
