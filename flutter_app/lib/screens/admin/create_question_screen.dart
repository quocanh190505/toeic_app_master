import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/admin_service.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

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

  int part = 1;
  String correctAnswer = 'A';
  String? audioPath;
  String? imagePath;
  bool loading = false;
  String? error;

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

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await service.createQuestion(
        part: part,
        content: contentCtrl.text.trim(),
        optionA: optionACtrl.text.trim(),
        optionB: optionBCtrl.text.trim(),
        optionC: optionCCtrl.text.trim(),
        optionD: optionDCtrl.text.trim(),
        correctAnswer: correctAnswer,
        explanation: explanationCtrl.text.trim(),
        audioPath: audioPath,
        imagePath: imagePath,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo câu hỏi thành công')),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm câu hỏi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: part,
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
                });
              },
            ),
            const SizedBox(height: 12),
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
              value: correctAnswer,
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
                  audioPath == null ? 'Chưa chọn file' : audioPath!.split('/').last,
                ),
                trailing: TextButton(
                  onPressed: pickAudio,
                  child: const Text('FilePicker'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Chọn hình ảnh'),
                subtitle: Text(
                  imagePath == null ? 'Chưa chọn file' : imagePath!.split('/').last,
                ),
                trailing: TextButton(
                  onPressed: pickImage,
                  child: const Text('FilePicker'),
                ),
              ),
            ),
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
                    : const Text('Tạo câu hỏi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}