import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'create_question_screen.dart';
import 'import_questions_screen.dart';
import 'manage_questions_screen.dart';

class TeacherScreen extends StatelessWidget {
  const TeacherScreen({super.key});

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
        title: const Text('Khu giáo viên'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4),
              AppTheme.bg,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF14B8A6),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Không gian làm đề cho giáo viên',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tạo câu hỏi mới, cập nhật nội dung và đưa đề từ Word hoặc PDF lên hệ thống để chờ duyệt.',
                    style: TextStyle(
                      color: Color(0xFFDCFCE7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _menuCard(
              context: context,
              title: 'Thêm câu hỏi',
              subtitle: 'Tạo câu hỏi mới và gán mức độ trước khi gửi duyệt.',
              icon: Icons.add_box_rounded,
              tint: const Color(0xFF0F766E),
              screen: const CreateQuestionScreen(),
            ),
            const SizedBox(height: 14),
            _menuCard(
              context: context,
              title: 'Danh sách câu hỏi',
              subtitle: 'Theo dõi trạng thái chờ duyệt, đã duyệt hoặc bị từ chối.',
              icon: Icons.quiz_rounded,
              tint: const Color(0xFF2563EB),
              screen: const ManageQuestionsScreen(),
            ),
            const SizedBox(height: 14),
            _menuCard(
              context: context,
              title: 'Import Word/PDF',
              subtitle: 'Upload file đề và để hệ thống tự tách thành câu hỏi trong một lần.',
              icon: Icons.upload_file_rounded,
              tint: const Color(0xFFB45309),
              screen: const ImportQuestionsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
