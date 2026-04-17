import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';

class ManagePremiumRequestsScreen extends StatefulWidget {
  const ManagePremiumRequestsScreen({super.key});

  @override
  State<ManagePremiumRequestsScreen> createState() =>
      _ManagePremiumRequestsScreenState();
}

class _ManagePremiumRequestsScreenState
    extends State<ManagePremiumRequestsScreen> {
  final service = AdminService();
  List<Map<String, dynamic>> requests = [];
  bool loading = true;
  String? filterStatus;
  String? error;

  int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      requests = await service.getPremiumPaymentRequests(status: filterStatus);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> reviewRequest(int requestId, String status) async {
    final noteCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(status == 'approved' ? 'Duyệt yêu cầu' : 'Từ chối yêu cầu'),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Ghi chú kiểm duyệt',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, noteCtrl.text.trim()),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (result == null) return;

    try {
      await service.reviewPremiumPaymentRequest(
        requestId: requestId,
        status: status,
        reviewNote: result,
      );
      await loadRequests();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Đã duyệt yêu cầu và kích hoạt Premium.'
                : 'Đã từ chối yêu cầu thanh toán.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt thanh toán Premium')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: filterStatus,
              decoration: const InputDecoration(labelText: 'Lọc trạng thái'),
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('Tất cả')),
                DropdownMenuItem<String?>(value: 'pending', child: Text('Chờ duyệt')),
                DropdownMenuItem<String?>(value: 'approved', child: Text('Đã duyệt')),
                DropdownMenuItem<String?>(value: 'rejected', child: Text('Đã từ chối')),
              ],
              onChanged: (value) async {
                filterStatus = value;
                await loadRequests();
              },
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (_, index) {
                          final item = requests[index];
                          final status = (item['status'] ?? 'pending').toString();
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (item['user_full_name'] ?? item['user_email'] ?? '')
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text((item['user_email'] ?? '').toString()),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Gói: ${item['months']} tháng • Số tiền: ${item['amount']} VND',
                                  ),
                                  if ((item['transaction_code'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Text('Mã giao dịch: ${item['transaction_code']}'),
                                  if ((item['note'] ?? '').toString().isNotEmpty)
                                    Text('Ghi chú người dùng: ${item['note']}'),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: status == 'approved'
                                          ? Colors.green.withValues(alpha: 0.12)
                                          : status == 'rejected'
                                              ? Colors.red.withValues(alpha: 0.12)
                                              : Colors.orange.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: status == 'approved'
                                            ? Colors.green
                                            : status == 'rejected'
                                                ? Colors.red
                                                : Colors.orange,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (status == 'pending')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => reviewRequest(
                                              _toInt(item['id']),
                                              'rejected',
                                            ),
                                            child: const Text('Từ chối'),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => reviewRequest(
                                              _toInt(item['id']),
                                              'approved',
                                            ),
                                            child: const Text('Duyệt'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if ((item['review_note'] ?? '')
                                      .toString()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text('Ghi chú kiểm duyệt: ${item['review_note']}'),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
