import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
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

  Widget _item({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget screen,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
          child: Icon(icon, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trang quản trị',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Quản lý người dùng, câu hỏi và dữ liệu hệ thống.',
                ),
              ],
            ),
          ),
          _item(
            context: context,
            title: 'Quản lý User',
            subtitle: 'Xem user, đổi role, reset mật khẩu',
            icon: Icons.people,
            screen: const ManageUsersScreen(),
          ),
          const SizedBox(height: 12),
          _item(
            context: context,
            title: 'Quản lý Câu hỏi',
            subtitle: 'Xem danh sách câu hỏi, lọc, xóa',
            icon: Icons.quiz,
            screen: const ManageQuestionsScreen(),
          ),
          const SizedBox(height: 12),
          _item(
            context: context,
            title: 'Thêm câu hỏi',
            subtitle: 'Tạo câu hỏi mới và upload audio/hình ảnh',
            icon: Icons.add_box,
            screen: const CreateQuestionScreen(),
          ),
        ],
      ),
    );
  }
}