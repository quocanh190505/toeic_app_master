import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/question_model.dart';
import '../../services/test_service.dart';
import '../practice/practice_screen.dart';

class PublishedTestsScreen extends StatefulWidget {
  const PublishedTestsScreen({super.key});

  @override
  State<PublishedTestsScreen> createState() => _PublishedTestsScreenState();
}

class _PublishedTestsScreenState extends State<PublishedTestsScreen> {
  final TestService service = TestService();
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> tests = [];

  @override
  void initState() {
    super.initState();
    loadTests();
  }

  Future<void> loadTests() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await service.getPublishedTests();
      if (!mounted) return;
      setState(() => tests = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> openPublishedTest(Map<String, dynamic> item) async {
    final rawId = item['id'];
    final testId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
    if (testId <= 0) return;
    final detail = await service.getPublishedTestDetail(testId);
    final rawQuestions = detail['questions'] as List? ?? const [];
    final questions = rawQuestions
        .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeScreen(
          testType: 'custom',
          title: detail['title']?.toString() ?? 'Đề đã phát hành',
          initialQuestions: questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kho đề đã phát hành')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: AppTheme.danger)))
              : tests.isEmpty
                  ? const Center(child: Text('Chưa có đề nào được phát hành cho học sinh.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: tests.length,
                      itemBuilder: (context, index) {
                        final item = tests[index];
                        return Card(
                          child: ListTile(
                            title: Text(item['title']?.toString() ?? 'Đề luyện tập'),
                            subtitle: Text('${item['test_type']} • ${item['total_questions']} câu'),
                            onTap: () => openPublishedTest(item),
                          ),
                        );
                      },
                    ),
    );
  }
}
