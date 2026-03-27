import 'package:flutter/material.dart';
import '../../services/test_service.dart';
import '../../core/theme/app_theme.dart';

class HistoryDetailScreen extends StatefulWidget {
  final int attemptId;
  const HistoryDetailScreen({super.key, required this.attemptId});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final service = TestService();
  Map<String, dynamic>? detail;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    detail = await service.getAttemptDetail(widget.attemptId);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final results = detail?['results'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài làm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('Score ${detail?['score'] ?? 0}'),
              subtitle: Text(
                'Đúng ${detail?['correct_count']}/${detail?['total_questions']}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...results.map((item) {
            final ok = item['is_correct'] == true;
            return Card(
              child: ListTile(
                title: Text(item['content'] ?? ''),
                subtitle: Text(
                  'Bạn chọn: ${item['selected_answer'] ?? 'Chưa chọn'}\n'
                  'Đúng: ${item['correct_answer']}\n'
                  'Giải thích: ${item['explanation'] ?? ''}',
                ),
                trailing: Icon(
                  ok ? Icons.check_circle : Icons.cancel,
                  color: ok ? AppTheme.success : AppTheme.danger,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}