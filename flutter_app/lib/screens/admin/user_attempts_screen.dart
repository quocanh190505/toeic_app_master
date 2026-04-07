import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../history/history_detail_screen.dart';

class UserAttemptsScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String userEmail;

  const UserAttemptsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<UserAttemptsScreen> createState() => _UserAttemptsScreenState();
}

class _UserAttemptsScreenState extends State<UserAttemptsScreen> {
  final service = AdminService();

  List<Map<String, dynamic>> attempts = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadAttempts();
  }

  Future<void> loadAttempts() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      attempts = await service.getAttempts(userId: widget.userId);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.userName.trim().isNotEmpty ? widget.userName : widget.userEmail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử làm bài'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFF6FF),
              AppTheme.bg,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: loadAttempts,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          error!,
                          style: const TextStyle(color: AppTheme.danger),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.history_rounded),
                            ),
                            title: Text(displayName),
                            subtitle: Text(widget.userEmail),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (attempts.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child:
                                  Text('Người dùng này chưa có bài làm nào.'),
                            ),
                          ),
                        ...attempts.map((item) {
                          final attemptId = item['attempt_id'] as int? ?? 0;
                          final testType = (item['test_type'] ?? 'mini')
                              .toString()
                              .toUpperCase();
                          final score = item['score'] ?? 0;
                          final correct = item['correct_count'] ?? 0;
                          final total = item['total_questions'] ?? 0;
                          final submittedAt =
                              (item['submitted_at'] ?? '').toString();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: ListTile(
                                title: Text('$testType • Score $score'),
                                subtitle: Text(
                                  'Đúng $correct/$total\n$submittedAt',
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                                onTap: attemptId <= 0
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => HistoryDetailScreen(
                                              attemptId: attemptId,
                                              adminMode: true,
                                            ),
                                          ),
                                        );
                                      },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
        ),
      ),
    );
  }
}
