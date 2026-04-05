import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/app_data_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/ptit_logo.dart';
import '../auth/login_screen.dart';
import '../history/history_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../practice/practice_screen.dart';
import '../profile/profile_screen.dart';
import '../vocabulary/vocabulary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeDashboardTab(),
    VocabularyScreen(),
    HistoryScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Từ vựng',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Lịch sử',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded),
            label: 'BXH',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Tôi',
          ),
        ],
      ),
    );
  }
}

class HomeDashboardTab extends StatefulWidget {
  const HomeDashboardTab({super.key});

  @override
  State<HomeDashboardTab> createState() => _HomeDashboardTabState();
}

class _HomeDashboardTabState extends State<HomeDashboardTab> {
  Map<String, dynamic>? dashboard;
  UserModel? user;
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final me = await AuthService().me();
      final data = await AppDataService().getDashboard();

      if (!mounted) return;

      setState(() {
        user = me;
        dashboard = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Không tải được dữ liệu: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openMiniTest() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 12),
                  child: Text(
                    'Chọn Part để luyện tập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.shuffle_rounded, color: Colors.white),
                  ),
                  title: const Text(
                    'Mini Test ngẫu nhiên',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Hệ thống tự chọn bộ câu hỏi phù hợp'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => const PracticeScreen(
                          testType: 'mini',
                          part: null,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: 7,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final partNumber = index + 1;
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        tileColor: Colors.white,
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE2E8F0),
                          child: Text(
                            '$partNumber',
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text('Luyện Part $partNumber'),
                        subtitle: const Text('Bắt đầu với bộ câu hỏi ngắn gọn'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (_) => PracticeScreen(
                                testType: 'mini',
                                part: partNumber,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFullTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PracticeScreen(testType: 'full'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('TOEIC MASTER PRO'),
          actions: [
            IconButton(
              onPressed: logout,
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Đăng xuất',
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: loadData,
                  child: const Text('Tải lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final progress = dashboard?['progress'] as Map<String, dynamic>? ?? {};
    final summary = dashboard?['summary'] as Map<String, dynamic>? ?? {};

    final highestScore = progress['highest_score'] ?? 0;
    final averageScore = progress['average_score'] ?? 0;
    final attemptsCount = summary['attempts_count'] ?? 0;
    final studiedWordsCount = summary['studied_words_count'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PtitLogo(width: 54, showSubtitle: false),
            SizedBox(width: 10),
            Text('TOEIC MASTER PRO'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
          ),
        ],
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
          onRefresh: loadData,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A),
                      AppTheme.primary,
                      AppTheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A0F62FE),
                      blurRadius: 28,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x100F172A),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const PtitLogo(
                          width: 92,
                          showSubtitle: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Xin chào, ${user?.fullName ?? ''}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mục tiêu hiện tại: ${user?.targetScore ?? 0} điểm TOEIC',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFDCF2FF),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _statChip(
                            'Điểm cao nhất',
                            '$highestScore',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statChip(
                            'Điểm trung bình',
                            '$averageScore',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      'Bài đã làm',
                      '$attemptsCount',
                      Icons.assignment_turned_in_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      'Từ đã học',
                      '$studiedWordsCount',
                      Icons.menu_book_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Chọn chế độ luyện tập',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Khởi động thật nhanh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mini Test phù hợp để luyện ngắn theo từng Part. Full Test phù hợp để mô phỏng bài thi hoàn chỉnh.',
                        style: TextStyle(
                          color: AppTheme.subText,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _openMiniTest,
                        icon: const Icon(Icons.flash_on_outlined),
                        label: const Text('Mini Test'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _openFullTest,
                        icon: const Icon(Icons.article_outlined),
                        label: const Text('Full Test'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: AppTheme.accent,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gợi ý: hãy duy trì mini test mỗi ngày và theo dõi lịch sử làm bài để thấy tiến độ rõ ràng hơn.',
                        style: TextStyle(
                          color: AppTheme.text,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFDCE7FF),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 28, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: AppTheme.subText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
