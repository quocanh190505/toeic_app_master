import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../services/test_service.dart';

class HistoryDetailScreen extends StatefulWidget {
  final int attemptId;
  final bool adminMode;

  const HistoryDetailScreen({
    super.key,
    required this.attemptId,
    this.adminMode = false,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final service = TestService();
  final adminService = AdminService();
  Map<String, dynamic>? detail;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    detail = widget.adminMode
        ? await adminService.getAttemptDetail(widget.attemptId)
        : await service.getAttemptDetail(widget.attemptId);
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
    final ownerLabel = widget.adminMode
        ? ((detail?['user_full_name'] ?? '').toString().trim().isNotEmpty
            ? '${detail?['user_full_name']} • ${detail?['user_email'] ?? ''}'
            : (detail?['user_email'] ?? '').toString())
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài làm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('Score ${detail?['score'] ?? 0}'),
              subtitle: Text(
                '${ownerLabel != null && ownerLabel.isNotEmpty ? '$ownerLabel\n' : ''}'
                'Đúng ${detail?['correct_count']}/${detail?['total_questions']}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...results.map((item) {
            final row = item is Map
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{};
            final ok = row['is_correct'] == true;
            final part = _toInt(row['part']);
            final hidesPart2Content = part == 2;
            final title = hidesPart2Content
                ? 'Part 2'
                : (row['content'] ?? '').toString();
            final explanation = (row['explanation'] ?? '').toString();
            final explanationLabel =
                hidesPart2Content ? 'Ẩn cho Part 2' : explanation;

            return Card(
              child: ListTile(
                title: Text(title),
                subtitle: Text(
                  'Bạn chọn: ${row['selected_answer'] ?? 'Chưa chọn'}\n'
                  'Đúng: ${row['correct_answer'] ?? ''}\n'
                  'Giải thích: $explanationLabel',
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
