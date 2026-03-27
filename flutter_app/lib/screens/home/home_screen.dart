import 'package:flutter/material.dart';
import '../practice/practice_screen.dart';
import '../profile/profile_screen.dart';
import '../history/history_screen.dart';
import '../vocabulary/vocabulary_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../../services/auth_service.dart';
import '../../services/app_data_service.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Từ vựng',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'BXH',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
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

  // --- HÀM MỚI: Hiển thị Bottom Sheet chọn Part cho Mini Test ---
  void _openMiniTest() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Chọn Part để luyện tập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              // Nút thi ngẫu nhiên
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.shuffle, color: Colors.white, size: 20),
                ),
                title: const Text('Mini Test Ngẫu Nhiên', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context); // Đóng bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PracticeScreen(
                        testType: 'mini',
                        part: null, // Truyền null để API lấy câu hỏi random
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              // Vòng lặp tạo ra 7 nút cho Part 1 đến Part 7
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final partNumber = index + 1;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          '$partNumber',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text('Part $partNumber'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context); // Đóng bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PracticeScreen(
                              testType: 'mini',
                              part: partNumber, // Truyền số part tương ứng
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
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TOEIC Master'),
          actions: [
            IconButton(
              onPressed: logout,
              icon: const Icon(Icons.logout),
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
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),
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
        title: const Text('TOEIC Master'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, ${user?.fullName ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mục tiêu: ${user?.targetScore ?? 0} điểm',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _statChip('Highest', '$highestScore'),
                      const SizedBox(width: 10),
                      _statChip('Average', '$averageScore'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
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
              'Bắt đầu luyện tập',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _openMiniTest, // Gọi hàm chọn Part mới tạo
              icon: const Icon(Icons.flash_on_outlined),
              label: const Text('Mini Test'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openFullTest,
              icon: const Icon(Icons.article_outlined),
              label: const Text('Full Test'),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Gợi ý',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Mini Test phù hợp để luyện nhanh. Full Test phù hợp để mô phỏng bài thi đầy đủ.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 26, color: AppTheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: AppTheme.subText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
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