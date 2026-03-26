import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/dashboard_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loaded) {
      final auth = context.read<AuthService>();
      final progress = context.read<ProgressService>();

      if (auth.userId != null) {
        progress.loadProgress(auth.userId!);
      }

      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final progress = context.watch<ProgressService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3157F6), Color(0xFF13C4A3)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào, User #${auth.userId ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mục tiêu hiện tại: 800+',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: () => context.go('/tests'),
                          child: const Text('Làm đề ngay'),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 72,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.35,
              children: [
                DashboardCard(
                  title: 'Từ đã học',
                  value: '${progress.studiedWords}',
                  icon: Icons.menu_book_rounded,
                ),
                DashboardCard(
                  title: 'Đề đã hoàn thành',
                  value: '${progress.completedTests}',
                  icon: Icons.fact_check_outlined,
                ),
                DashboardCard(
                  title: 'Chuỗi ngày học',
                  value: '${progress.currentStreak} ngày',
                  icon: Icons.local_fire_department_outlined,
                ),
                DashboardCard(
                  title: 'Tiến độ chung',
                  value:
                      '${(progress.overallProgress * 100).toStringAsFixed(0)}%',
                  icon: Icons.show_chart_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.go('/practice'),
                    icon: const Icon(Icons.headphones_outlined),
                    label: const Text('Luyện Listening / Reading'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/tests'),
                    icon: const Icon(Icons.assignment_outlined),
                    label: const Text('Mock Test'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}