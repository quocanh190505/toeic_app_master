import 'package:flutter/material.dart';

import '../../services/app_data_service.dart';
import '../../services/auth_service.dart';
import '../../models/progress_model.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final dataService = AppDataService();
  final authService = AuthService();

  ProgressModel? progress;
  Map<String, dynamic> partStats = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await dataService.getProgress();
    final s = await dataService.getPartStats();
    setState(() {
      progress = p;
      partStats = s;
      loading = false;
    });
  }

  Future<void> changePasswordDialog() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.changePassword(
                oldPassword: oldCtrl.text.trim(),
                newPassword: newCtrl.text.trim(),
              );
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đổi mật khẩu thành công')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Widget buildPartStats() {
    final entries = partStats.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    return Column(
      children: entries.map((e) {
        final value = e.value as Map<String, dynamic>;
        return Card(
          child: ListTile(
            title: Text('Part ${e.key}'),
            subtitle: Text(
              'Correct: ${value['correct']}/${value['total']} · Accuracy: ${value['accuracy']}%',
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading || progress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ & tiến độ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Studied words'),
                  trailing: Text('${progress!.studiedWords}'),
                ),
                ListTile(
                  title: const Text('Completed tests'),
                  trailing: Text('${progress!.completedTests}'),
                ),
                ListTile(
                  title: const Text('Overall progress'),
                  trailing: Text('${progress!.overallProgress}%'),
                ),
                ListTile(
                  title: const Text('Highest score'),
                  trailing: Text('${progress!.highestScore}'),
                ),
                ListTile(
                  title: const Text('Average score'),
                  trailing: Text('${progress!.averageScore}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: changePasswordDialog,
            icon: const Icon(Icons.lock_reset),
            label: const Text('Đổi mật khẩu'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thống kê theo part',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          buildPartStats(),
        ],
      ),
    );
  }
}