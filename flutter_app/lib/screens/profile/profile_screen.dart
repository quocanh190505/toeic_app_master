import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/progress_model.dart';
import '../../services/app_data_service.dart';
import '../../services/auth_service.dart';

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
    if (!mounted) return;
    setState(() => loading = true);

    try {
      // 1. Tải tiến độ độc lập
      try {
        final p = await dataService.getProgress();
        if (mounted) setState(() => progress = p);
      } catch (e) {
        debugPrint("Lỗi tải Progress: $e");
      }

      // 2. Tải thống kê Part độc lập
      try {
        final s = await dataService.getPartStats();
        if (mounted) setState(() => partStats = s);
      } catch (e) {
        debugPrint("Lỗi tải PartStats: $e");
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & tiến độ'),
        actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (progress != null)
                    _buildProgressCard()
                  else
                    const Center(child: Text("Chưa có dữ liệu tiến độ")),
                  const SizedBox(height: 16),
                  _buildChangePasswordCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Thống kê theo Part',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildPartStatsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _rowInfo('Từ đã học', '${progress!.studiedWords} từ'),
            const Divider(),
            _rowInfo('Bài thi đã xong', '${progress!.completedTests} bài'),
            const Divider(),
            _rowInfo('Điểm cao nhất', '${progress!.highestScore} điểm'),
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary)),
        ],
      ),
    );
  }

  Widget _buildChangePasswordCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_reset_rounded, color: AppTheme.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đổi mật khẩu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Cập nhật mật khẩu mới để bảo vệ tài khoản của bạn.',
              style: TextStyle(color: AppTheme.subText, height: 1.4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showChangePasswordSheet,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Mở form đổi mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePasswordSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  Widget _buildPartStatsList() {
    if (partStats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Chưa có dữ liệu thống kê"),
        ),
      );
    }
    final entries = partStats.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    return Column(
      children: entries.map((e) {
        final val = e.value as Map<String, dynamic>;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: Text(
                e.key,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text('Part ${e.key}'),
            subtitle: Text(
              'Đúng: ${val['correct']}/${val['total']} · Accuracy: ${val['accuracy']}%',
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _saving = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPassword = _oldPasswordCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = 'Vui lòng nhập đầy đủ thông tin.');
      return;
    }

    if (newPassword.length < 6) {
      setState(() => _error = 'Mật khẩu mới phải có ít nhất 6 ký tự.');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _error = 'Mật khẩu xác nhận không khớp.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công.'),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Đổi mật khẩu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập mật khẩu hiện tại và mật khẩu mới của bạn.',
              style: TextStyle(color: AppTheme.subText, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _oldPasswordCtrl,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscureOld = !_obscureOld);
                  },
                  icon: Icon(
                    _obscureOld
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscureNew = !_obscureNew);
                  },
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Cập nhật mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
