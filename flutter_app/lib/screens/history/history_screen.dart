import 'package:flutter/material.dart';
import '../../services/test_service.dart';
import 'history_detail_screen.dart';
import '../../models/attempt_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final service = TestService();
  List<AttemptModel> attempts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    attempts = await service.getAttempts();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử làm bài')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: attempts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = attempts[index];
          return Card(
            child: ListTile(
              title: Text('${item.testType.toUpperCase()} · Score ${item.score}'),
              subtitle: Text(
                'Đúng ${item.correctCount}/${item.totalQuestions}\n${item.submittedAt}',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryDetailScreen(attemptId: item.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}