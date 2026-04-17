import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'generate_test_screen.dart';
import 'manage_premium_requests_screen.dart';
import 'manage_questions_screen.dart';

class ModeratorScreen extends StatelessWidget {
  const ModeratorScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _menuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color tint,
    required Widget screen,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: tint, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.subText,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khu kiểm duyệt'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9A3412), Color(0xFFF97316)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không gian kiểm duyệt nội dung',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Duyệt câu hỏi, duyệt thanh toán Premium và sinh đề từ ngân hàng câu hỏi đạt chuẩn.',
                  style: TextStyle(color: Color(0xFFFFEDD5), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _menuCard(
            context: context,
            title: 'Duyệt câu hỏi',
            subtitle: 'Xem các câu đang chờ duyệt và cập nhật trạng thái.',
            icon: Icons.fact_check_rounded,
            tint: const Color(0xFFF97316),
            screen: const ManageQuestionsScreen(),
          ),
          const SizedBox(height: 14),
          _menuCard(
            context: context,
            title: 'Duyệt thanh toán Premium',
            subtitle: 'Kích hoạt Premium cho người dùng sau khi kiểm tra giao dịch.',
            icon: Icons.payments_rounded,
            tint: const Color(0xFF0F766E),
            screen: const ManagePremiumRequestsScreen(),
          ),
          const SizedBox(height: 14),
          _menuCard(
            context: context,
            title: 'Sinh đề tự động',
            subtitle: 'Tạo đề mới từ ngân hàng câu hỏi đã được duyệt.',
            icon: Icons.auto_awesome_rounded,
            tint: const Color(0xFF2563EB),
            screen: const GenerateTestScreen(),
          ),
        ],
      ),
    );
  }
}
