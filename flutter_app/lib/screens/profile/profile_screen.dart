import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/progress_model.dart';
import '../../models/user_model.dart';
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

  static const String _bankName = 'MB Bank';
  static const String _bankId = '970422';
  static const String _accountNumber = '0123419052005';
  static const String _accountHolder = 'DOAN QUOC ANH';
  static const Map<int, int> _planPrices = {
    1: 79000,
    3: 199000,
    12: 599000,
  };

  ProgressModel? progress;
  UserModel? user;
  List<Map<String, dynamic>> premiumRequests = [];
  bool loading = true;
  bool submitting = false;
  bool showPremiumRegistration = false;
  int selectedMonths = 1;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final me = await authService.me();
      final p = await dataService.getProgress();
      final requests = await authService.getMyPremiumRequests();
      if (!mounted) return;
      setState(() {
        user = me;
        progress = p;
        premiumRequests = requests;
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  int get _selectedAmount => _planPrices[selectedMonths] ?? 79000;

  String _formatCurrency(int amount) {
    final raw = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final indexFromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }

  String get _transferContent {
    final userId = user?.id ?? 0;
    return 'PREMIUM${selectedMonths}M$userId';
  }

  String get _dynamicQrUrl {
    final uri = Uri.https(
      'img.vietqr.io',
      '/image/$_bankId-$_accountNumber-compact2.png',
      {
        'amount': _selectedAmount.toString(),
        'addInfo': _transferContent,
        'accountName': _accountHolder,
      },
    );
    return uri.toString();
  }

  Future<void> _openPremiumRequestDialog() async {
    final transactionCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Gửi yêu cầu Premium $selectedMonths tháng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số tiền cần chuyển: ${_formatCurrency(_selectedAmount)}'),
            const SizedBox(height: 8),
            Text('Nội dung chuyển khoản: $_transferContent'),
            const SizedBox(height: 12),
            TextField(
              controller: transactionCtrl,
              decoration: const InputDecoration(
                labelText: 'Mã giao dịch',
                hintText: 'Nhập mã giao dịch hoặc mã tham chiếu',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Ví dụ: đã chuyển khoản lúc 10:30 từ MB Bank',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => submitting = true);
    try {
      await authService.requestPremiumUpgrade(
        months: selectedMonths,
        transactionCode: transactionCtrl.text.trim(),
        note: noteCtrl.text.trim(),
      );
      await load();
      if (!mounted) return;
      setState(() => showPremiumRegistration = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi yêu cầu nâng cấp Premium. Vui lòng chờ kiểm duyệt.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu mới'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (newCtrl.text.trim().length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu mới phải có ít nhất 6 ký tự.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    if (newCtrl.text.trim() != confirmCtrl.text.trim()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu nhập lại không khớp.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => submitting = true);
    try {
      await authService.changePassword(
        oldPassword: oldCtrl.text.trim(),
        newPassword: newCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  Future<void> _cancelPremium() async {
    setState(() => submitting = true);
    try {
      final updatedUser = await authService.cancelPremium();
      if (!mounted) return;
      setState(() => user = updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật trạng thái hủy gia hạn Premium.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        actions: [
          IconButton(
            tooltip: 'Đổi mật khẩu',
            onPressed: submitting ? null : _showChangePasswordDialog,
            icon: const Icon(Icons.lock_reset_rounded),
          ),
          IconButton(
            tooltip: 'Tải lại',
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAccountCard(),
                  const SizedBox(height: 16),
                  _buildMembershipSummaryCard(),
                  const SizedBox(height: 16),
                  if (showPremiumRegistration && user?.isPremium != true) ...[
                    _buildPremiumRegistrationCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildPaymentHistoryCard(),
                  const SizedBox(height: 16),
                  if (progress != null) _buildProgressCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tài khoản',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              user?.fullName ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: AppTheme.subText),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: submitting ? null : _showChangePasswordDialog,
                icon: const Icon(Icons.lock_reset_rounded),
                label: const Text('Đổi mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipSummaryCard() {
    final isPremium = user?.isPremium == true;
    final expiresAt = user?.premiumExpiresAt ?? '';
    final cancelAtPeriodEnd = user?.premiumCancelAtPeriodEnd == true;
    final latestPending = premiumRequests.cast<Map<String, dynamic>?>().firstWhere(
          (item) => (item?['status'] ?? '').toString() == 'pending',
          orElse: () => null,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPremium ? 'Gói hiện tại: Premium' : 'Gói hiện tại: Basic',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isPremium
                  ? 'Bạn đang sử dụng các tính năng Premium.'
                  : 'Bạn đang dùng gói Basic. Nâng cấp để mở khóa Full Test và kho đề đã phát hành.',
            ),
            if (isPremium && expiresAt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Hiệu lực đến: $expiresAt'),
            ],
            if (latestPending != null) ...[
              const SizedBox(height: 8),
              Text(
                'Bạn đang có yêu cầu ${latestPending['months']} tháng chờ duyệt.',
                style: const TextStyle(color: AppTheme.accent),
              ),
            ],
            if (isPremium && cancelAtPeriodEnd) ...[
              const SizedBox(height: 8),
              const Text(
                'Đã lên lịch hủy ở cuối chu kỳ. Bạn vẫn dùng Premium đến hết hạn.',
                style: TextStyle(color: AppTheme.danger),
              ),
            ],
            const SizedBox(height: 12),
            if (!isPremium)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () {
                          setState(() {
                            showPremiumRegistration = !showPremiumRegistration;
                          });
                        },
                  child: Text(
                    showPremiumRegistration
                        ? 'Ẩn đăng ký Premium'
                        : 'Đăng ký tài khoản Premium',
                  ),
                ),
              ),
            if (isPremium)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: submitting ? null : _cancelPremium,
                  child: Text(
                    cancelAtPeriodEnd ? 'Đã hủy gia hạn' : 'Hủy đăng ký',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumRegistrationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đăng ký Premium',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chọn gói phù hợp, quét mã QR để chuyển khoản, rồi gửi yêu cầu chờ kiểm duyệt.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _planPrices.entries.map((entry) {
                final isSelected = selectedMonths == entry.key;
                return ChoiceChip(
                  label: Text('${entry.key} tháng • ${_formatCurrency(entry.value)}'),
                  selected: isSelected,
                  onSelected: submitting
                      ? null
                      : (_) {
                          setState(() => selectedMonths = entry.key);
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Số tiền cần chuyển: ${_formatCurrency(_selectedAmount)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Ngân hàng: $_bankName\nSố tài khoản: $_accountNumber\nChủ tài khoản: $_accountHolder',
              style: const TextStyle(color: AppTheme.subText, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Nội dung chuyển khoản: $_transferContent',
              style: const TextStyle(color: AppTheme.subText),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: Colors.white,
                    child: Image.network(
                      _dynamicQrUrl,
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => Container(
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFFF8FAFC),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Không tải được mã QR thanh toán.',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.text,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Hãy kiểm tra kết nối mạng hoặc thử chọn lại gói Premium.',
                              style: TextStyle(color: AppTheme.subText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitting ? null : _openPremiumRequestDialog,
                child: Text(
                  'Gửi yêu cầu ${selectedMonths} tháng • ${_formatCurrency(_selectedAmount)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử yêu cầu Premium',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (premiumRequests.isEmpty)
              const Text('Bạn chưa gửi yêu cầu nâng cấp Premium nào.')
            else
              ...premiumRequests.take(5).map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${item['months']} tháng • ${_formatCurrency(_toInt(item['amount']))}',
                      ),
                      subtitle: Text(
                        'Trạng thái: ${_translateStatus((item['status'] ?? '').toString())}'
                        '${(item['transaction_code'] ?? '').toString().isNotEmpty ? '\nMã GD: ${item['transaction_code']}' : ''}',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
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
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _translateStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return value;
    }
  }
}
