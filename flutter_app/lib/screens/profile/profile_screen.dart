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
                  if (progress != null) _buildProgressCard() else const Center(child: Text("Chưa có dữ liệu tiến độ")),
                  const SizedBox(height: 20),
                  const Text('Thống kê theo Part', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        ],
      ),
    );
  }

  Widget _buildPartStatsList() {
    if (partStats.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Chưa có dữ liệu thống kê")));
    final entries = partStats.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    return Column(
      children: entries.map((e) {
        final val = e.value as Map<String, dynamic>;
        return Card(
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppTheme.primary, child: Text(e.key, style: const TextStyle(color: Colors.white))),
            title: Text('Part ${e.key}'),
            subtitle: Text('Đúng: ${val['correct']}/${val['total']} · Accuracy: ${val['accuracy']}%'),
          ),
        );
      }).toList(),
    );
  }
}