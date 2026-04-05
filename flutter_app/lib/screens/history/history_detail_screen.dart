import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/test_service.dart';

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

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final results = detail?['results'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiet bai lam')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('Score ${detail?['score'] ?? 0}'),
              subtitle: Text(
                'Dung ${detail?['correct_count']}/${detail?['total_questions']}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...results.map((item) {
            final row = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
            final ok = row['is_correct'] == true;
            final part = _toInt(row['part']);
            final hidesPart2Content = part == 2;
            final title = hidesPart2Content
                ? 'Part 2'
                : (row['content'] ?? '').toString();
            final explanation = (row['explanation'] ?? '').toString();
            final explanationLabel = hidesPart2Content
                ? 'An cho Part 2'
                : explanation;

            return Card(
              child: ListTile(
                title: Text(title),
                subtitle: Text(
                  'Ban chon: ${row['selected_answer'] ?? 'Chua chon'}\n'
                  'Dung: ${row['correct_answer'] ?? ''}\n'
                  'Giai thich: $explanationLabel',
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
