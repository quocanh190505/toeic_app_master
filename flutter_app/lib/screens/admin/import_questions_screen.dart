import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class ImportQuestionsScreen extends StatefulWidget {
  const ImportQuestionsScreen({super.key});

  @override
  State<ImportQuestionsScreen> createState() => _ImportQuestionsScreenState();
}

class _ImportQuestionsScreenState extends State<ImportQuestionsScreen> {
  final AdminService service = AdminService();
  String? filePath;
  bool previewLoading = false;
  bool submitLoading = false;
  String? error;
  String? success;
  String? submissionStatus;
  List<Map<String, dynamic>> previewQuestions = [];

  bool get _isJsonFile => filePath != null && filePath!.toLowerCase().endsWith('.json');

  Future<void> pickImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'pdf', 'json'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        filePath = result.files.single.path!;
        error = null;
        success = null;
        submissionStatus = null;
        previewQuestions = [];
      });
    }
  }

  Future<void> previewFile() async {
    if (filePath == null || filePath!.isEmpty) {
      setState(() => error = 'Hãy chọn file Word, PDF hoặc JSON trước khi xem trước.');
      return;
    }
    setState(() {
      previewLoading = true;
      error = null;
      success = null;
      submissionStatus = null;
    });
    try {
      final result = _isJsonFile
          ? await service.previewQuestionsJson(filePath!)
          : await service.previewQuestionsDocument(filePath!);
      final rawQuestions = result['questions'] as List? ?? const [];
      previewQuestions = rawQuestions.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      submissionStatus = result['submission_status']?.toString();
      success = 'Đã đọc được ${result['count'] ?? 0} câu hỏi. Hãy kiểm tra rồi nộp.';
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => previewLoading = false);
    }
  }

  Future<void> submitFile() async {
    if (filePath == null || filePath!.isEmpty) {
      setState(() => error = 'Hãy chọn file trước khi nộp.');
      return;
    }
    if (previewQuestions.isEmpty) {
      setState(() => error = 'Hãy xem trước nội dung trước khi nộp lên chờ duyệt.');
      return;
    }
    setState(() {
      submitLoading = true;
      error = null;
      success = null;
    });
    try {
      final result = _isJsonFile
          ? await service.importQuestionsJson(filePath!)
          : await service.importQuestionsDocument(filePath!);
      success = 'Đã nộp ${result['count'] ?? 0} câu hỏi lên hàng chờ duyệt.';
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => submitLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFileName = filePath == null ? 'Chưa chọn file' : filePath!.split(Platform.pathSeparator).last;
    return Scaffold(
      appBar: AppBar(title: const Text('Import đề từ Word/PDF')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_open_rounded),
              title: const Text('Chọn file import'),
              subtitle: Text(selectedFileName),
              trailing: TextButton(
                onPressed: previewLoading || submitLoading ? null : pickImportFile,
                child: const Text('Chọn file'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: previewLoading || submitLoading ? null : previewFile,
            child: const Text('Xem trước câu hỏi'),
          ),
          if (previewQuestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: submitLoading ? null : submitFile,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Nộp lên chờ duyệt'),
            ),
          ],
          if (submissionStatus != null) ...[
            const SizedBox(height: 12),
            Text('Trạng thái sau khi nộp: $submissionStatus'),
          ],
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(color: AppTheme.danger)),
          ],
          if (success != null) ...[
            const SizedBox(height: 16),
            Text(success!, style: const TextStyle(color: AppTheme.success)),
          ],
          if (previewQuestions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Xem trước ${previewQuestions.length} câu hỏi'),
            const SizedBox(height: 12),
            ...previewQuestions.asMap().entries.map((entry) {
              final q = entry.value;
              return Card(
                child: ListTile(
                  title: Text('Câu ${entry.key + 1} • Part ${q['part']} • ${q['difficulty'] ?? 'medium'}'),
                  subtitle: Text(q['content']?.toString() ?? ''),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
