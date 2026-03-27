import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final targetScoreCtrl = TextEditingController(text: '750');

  bool loading = false;
  String? message;
  String? error;

  Future<void> submit() async {
    setState(() {
      loading = true;
      message = null;
      error = null;
    });

    try {
      await AuthService().register(
        fullName: fullNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        targetScore: int.tryParse(targetScoreCtrl.text.trim()) ?? 750,
      );
      setState(() => message = 'Đăng ký thành công. Quay lại để đăng nhập.');
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    targetScoreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: fullNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Họ tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: targetScoreCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Mục tiêu điểm',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
          ),
          const SizedBox(height: 16),
          if (message != null)
            Text(message!, style: const TextStyle(color: AppTheme.success)),
          if (error != null)
            Text(error!, style: const TextStyle(color: AppTheme.danger)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: loading ? null : submit,
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Tạo tài khoản'),
          ),
        ],
      ),
    );
  }
}