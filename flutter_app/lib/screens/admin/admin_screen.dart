import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/ptit_logo.dart';
import '../auth/login_screen.dart';
import 'admin_topic_screen.dart';
import 'create_question_screen.dart';
import 'manage_questions_screen.dart';
import 'manage_users_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 12),
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
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PtitLogo(width: 54, showSubtitle: false),
            SizedBox(width: 10),
            Text('Trang quản trị'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF2563EB),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A2563EB),
                    blurRadius: 26,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 18),
                  const Text(
                    'Quản trị hệ thống thông minh và gọn gàng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Quản lý người dùng, chủ đề, từ vựng và câu hỏi trong một giao diện hiện đại, dễ theo dõi hơn.',
                    style: TextStyle(
                      color: Color(0xFFDCE7FF),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          value: '4',
                          label: 'Mô-đun chính',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatChip(
                          value: 'Admin',
                          label: 'Quyền hiện tại',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Chức năng chính',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 14),
            _menuCard(
              context: context,
              title: 'Quản lý Chủ đề và Từ vựng',
              subtitle:
                  'Thêm, sửa, xóa chủ đề TOEIC và danh sách từ vựng theo từng chủ đề.',
              icon: Icons.auto_stories_rounded,
              tint: const Color(0xFF2563EB),
              screen: const AdminTopicScreen(),
            ),
            const SizedBox(height: 14),
            _menuCard(
              context: context,
              title: 'Quản lý người dùng',
              subtitle:
                  'Xem danh sách user, đổi role, reset mật khẩu và xóa tài khoản.',
              icon: Icons.people_alt_rounded,
              tint: const Color(0xFF0F766E),
              screen: const ManageUsersScreen(),
            ),
            const SizedBox(height: 14),
            _menuCard(
              context: context,
              title: 'Quản lý câu hỏi',
              subtitle:
                  'Theo dõi danh sách câu hỏi, lọc theo part và xóa nội dung không cần thiết.',
              icon: Icons.quiz_rounded,
              tint: const Color(0xFFF97316),
              screen: const ManageQuestionsScreen(),
            ),
            const SizedBox(height: 14),
            _menuCard(
              context: context,
              title: 'Thêm câu hỏi',
              subtitle:
                  'Tạo câu hỏi mới và upload file audio hoặc hình ảnh nhanh hơn.',
              icon: Icons.add_box_rounded,
              tint: const Color(0xFF7C3AED),
              screen: const CreateQuestionScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFDCE7FF),
            ),
          ),
        ],
      ),
    );
  }
}
