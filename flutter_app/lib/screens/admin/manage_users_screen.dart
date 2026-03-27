import 'package:flutter/material.dart';

import '../../services/admin_service.dart';

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
    final newRole = currentRole == 'admin' ? 'user' : 'admin';

    try {
      await service.updateUserRole(userId: userId, role: newRole);
      await loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đổi role thành $newRole')),
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

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Reset mật khẩu'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu mới',
            ),
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
                    const SnackBar(content: Text('Reset mật khẩu thành công')),
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý User')),
      body: error != null
          ? Center(child: Text(error!))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, index) {
                final u = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(u['full_name'] ?? ''),
                    subtitle: Text(
                      '${u['email']}\nRole: ${u['role']}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'role') {
                          changeRole(u['id'], u['role']);
                        } else if (value == 'reset') {
                          resetPasswordDialog(u['id']);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'role',
                          child: Text('Đổi role'),
                        ),
                        PopupMenuItem(
                          value: 'reset',
                          child: Text('Reset mật khẩu'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}