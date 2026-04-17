import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class GenerateTestScreen extends StatefulWidget {
  const GenerateTestScreen({super.key});

  @override
  State<GenerateTestScreen> createState() => _GenerateTestScreenState();
}

class _GenerateTestScreenState extends State<GenerateTestScreen> {
  final AdminService service = AdminService();
  final avoidCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  String testType = 'full';
  int? selectedPart = 1;
  bool loading = false;
  bool publishing = false;
  String? error;
  String? publishMessage;
  Map<String, dynamic>? result;

  List<int> parseAvoidIds() => avoidCtrl.text
      .split(',')
      .map((item) => int.tryParse(item.trim()))
      .whereType<int>()
      .toList();

  List<int> generatedQuestionIds() {
    final questions = (result?['questions'] as List?) ?? const [];
    return questions
        .map((item) => Map<String, dynamic>.from(item as Map))
        .map((item) => item['id'])
        .map(
          (value) =>
              value is int ? value : int.tryParse(value?.toString() ?? ''),
        )
        .whereType<int>()
        .toList();
  }

  Future<void> generate() async {
    setState(() {
      loading = true;
      error = null;
      publishMessage = null;
    });
    try {
      result = await service.generateTest(
        testType: testType,
        part: testType == 'mini' ? selectedPart : null,
        avoidQuestionIds: parseAvoidIds(),
      );
      titleCtrl.text = testType == 'full'
          ? 'Full Test ${DateTime.now().day}/${DateTime.now().month}'
          : 'Mini Test Part ${selectedPart ?? 1}';
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> publishTest() async {
    final questionIds = generatedQuestionIds();
    if (questionIds.isEmpty) {
      setState(() => error = 'Hãy sinh đề trước khi lưu vào kho đề.');
      return;
    }
    if (titleCtrl.text.trim().isEmpty) {
      setState(() => error = 'Hãy nhập tên đề trước khi phát hành.');
      return;
    }
    setState(() {
      publishing = true;
      error = null;
      publishMessage = null;
    });
    try {
      final saved = await service.createPublishedTest(
        title: titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        testType: testType,
        part: testType == 'mini' ? selectedPart : null,
        questionIds: questionIds,
      );
      publishMessage =
          'Đã đưa "${saved['title'] ?? titleCtrl.text.trim()}" vào kho đề học sinh.';
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => publishing = false);
    }
  }

  @override
  void dispose() {
    avoidCtrl.dispose();
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = (result?['questions'] as List?) ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Sinh đề tự động')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: testType,
            decoration: const InputDecoration(labelText: 'Loại đề'),
            items: const [
              DropdownMenuItem(value: 'full', child: Text('Full Test')),
              DropdownMenuItem(value: 'mini', child: Text('Mini Test theo part')),
            ],
            onChanged: (value) => setState(() => testType = value ?? 'full'),
          ),
          const SizedBox(height: 12),
          if (testType == 'mini')
            DropdownButtonFormField<int>(
              initialValue: selectedPart,
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
              onChanged: (value) => setState(() => selectedPart = value ?? 1),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: avoidCtrl,
            decoration: const InputDecoration(
              labelText: 'ID câu hỏi cần tránh',
              helperText: 'Nhập dạng 12,34,56 để loại khỏi đề sinh ra',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loading ? null : generate,
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Sinh đề'),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Tên đề phát hành',
              hintText: 'Ví dụ: Full Test tháng 4',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả ngắn',
              hintText: 'Hiển thị cho học sinh trong kho đề',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: publishing ? null : publishTest,
            icon: const Icon(Icons.publish_rounded),
            label: const Text('Lưu vào kho đề học sinh'),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(color: AppTheme.danger)),
          ],
          if (publishMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              publishMessage!,
              style: const TextStyle(color: AppTheme.success),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 20),
            Text('Tổng số câu: ${result!['total_questions']}'),
            const SizedBox(height: 12),
            ...questions.take(20).map((item) {
              final q = Map<String, dynamic>.from(item as Map);
              return Card(
                child: ListTile(
                  title: Text('Part ${q['part']} - ${q['content']}'),
                  subtitle: Text(
                    'ID: ${q['id']} | ${q['difficulty'] ?? 'medium'} | ${q['approval_status'] ?? 'approved'}',
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
