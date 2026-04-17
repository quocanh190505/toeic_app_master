import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';
import 'user_attempts_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final AdminService service = AdminService();

  List<Map<String, dynamic>> users = [];
  bool loading = true;
  String? error;

  int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      users = await service.getUsers();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> changeRole(int userId, String currentRole) async {
    String selectedRole = currentRole;
    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Cập nhật role'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(
                    value: 'moderator',
                    child: Text('Moderator'),
                  ),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  setModalState(() {
                    selectedRole = value ?? currentRole;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedRole),
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result == currentRole) return;

    try {
      await service.updateUserRole(userId: userId, role: result);
      await loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đổi role thành $result')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> resetPasswordDialog(int userId) async {
    final ctrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Reset mật khẩu'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await service.resetUserPassword(
                    userId: userId,
                    newPassword: ctrl.text.trim(),
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reset mật khẩu thành công'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUserDialog(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Xóa người dùng'),
          content: Text(
            'Bạn có chắc muốn xóa tài khoản "${user['full_name'] ?? user['email']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.danger,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await service.deleteUser(_toInt(user['id']));
      await loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa người dùng')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Color roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFF1D4ED8);
      case 'teacher':
        return const Color(0xFF7C3AED);
      case 'moderator':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF0F766E);
    }
  }

  void openUserAttempts(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserAttemptsScreen(
          userId: _toInt(user['id']),
          userName: (user['full_name'] ?? '').toString(),
          userEmail: (user['email'] ?? '').toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng')),
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
          onRefresh: loadUsers,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(error!, style: const TextStyle(color: AppTheme.text)),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: users.map((u) {
                        final role = (u['role'] ?? 'user').toString();
                        final fullName = (u['full_name'] ?? '').toString();
                        final email = (u['email'] ?? '').toString();
                        final initialsSource = fullName.isNotEmpty ? fullName : email;
                        final initials = initialsSource.isNotEmpty
                            ? initialsSource.substring(0, 1).toUpperCase()
                            : '?';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: const Color(0xFFDBEAFE),
                                        foregroundColor: AppTheme.primary,
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fullName.isEmpty
                                                  ? 'Chưa cập nhật tên'
                                                  : fullName,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.text,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              email,
                                              style: const TextStyle(
                                                color: AppTheme.subText,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 7,
                                              ),
                                              decoration: BoxDecoration(
                                                color: roleColor(role)
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                role.toUpperCase(),
                                                style: TextStyle(
                                                  color: roleColor(role),
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => openUserAttempts(u),
                                        icon:
                                            const Icon(Icons.history_rounded),
                                        label: const Text('Lịch sử làm bài'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            changeRole(_toInt(u['id']), role),
                                        icon: const Icon(Icons.swap_horiz),
                                        label: const Text('Đổi role'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            resetPasswordDialog(_toInt(u['id'])),
                                        icon: const Icon(Icons.lock_reset),
                                        label: const Text('Reset mật khẩu'),
                                      ),
                                      FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppTheme.danger,
                                        ),
                                        onPressed: () => deleteUserDialog(u),
                                        icon:
                                            const Icon(Icons.delete_outline),
                                        label: const Text('Xóa'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
        ),
      ),
    );
  }
}
