import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../services/admin_service.dart';
import 'create_question_screen.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  final AdminService service = AdminService();

  List<Map<String, dynamic>> questions = [];
  bool loading = true;
  String? error;
  int? selectedPart;
  String? selectedApprovalStatus;
  String role = 'admin';

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    role = (prefs.getString('role') ?? 'admin').toLowerCase();
    await loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      questions = await service.getQuestions(
        part: selectedPart,
        approvalStatus: selectedApprovalStatus,
      );
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

  Future<void> deleteQuestion(int id) async {
    try {
      await service.deleteQuestion(id);
      await loadQuestions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa câu hỏi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> changeApproval(int questionId, String status) async {
    try {
      await service.updateQuestionApproval(
        questionId: questionId,
        approvalStatus: status,
      );
      await loadQuestions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật trạng thái thành $status')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _openQuestionForm({Map<String, dynamic>? question}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateQuestionScreen(question: question),
      ),
    );
    await loadQuestions();
  }

  bool get canCreate => role == 'admin' || role == 'teacher';
  bool get canApprove => role == 'admin' || role == 'moderator';
  bool get canDelete => role == 'admin';
  bool get canEdit => role == 'admin' || role == 'teacher';

  int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF15803D);
      case 'rejected':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFFB45309);
    }
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'hard':
        return const Color(0xFFB91C1C);
      case 'easy':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF1D4ED8);
    }
  }

  Widget _badge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý câu hỏi'),
        actions: [
          if (canCreate)
            IconButton(
              onPressed: () => _openQuestionForm(),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<int?>(
                  initialValue: selectedPart,
                  decoration: const InputDecoration(labelText: 'Lọc theo Part'),
                  items: const [
                    DropdownMenuItem<int?>(value: null, child: Text('Tất cả')),
                    DropdownMenuItem<int?>(value: 1, child: Text('Part 1')),
                    DropdownMenuItem<int?>(value: 2, child: Text('Part 2')),
                    DropdownMenuItem<int?>(value: 3, child: Text('Part 3')),
                    DropdownMenuItem<int?>(value: 4, child: Text('Part 4')),
                    DropdownMenuItem<int?>(value: 5, child: Text('Part 5')),
                    DropdownMenuItem<int?>(value: 6, child: Text('Part 6')),
                    DropdownMenuItem<int?>(value: 7, child: Text('Part 7')),
                  ],
                  onChanged: (value) async {
                    selectedPart = value;
                    await loadQuestions();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: selectedApprovalStatus,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái duyệt',
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tất cả'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'pending',
                      child: Text('Chờ duyệt'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'approved',
                      child: Text('Đã duyệt'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'rejected',
                      child: Text('Từ chối'),
                    ),
                  ],
                  onChanged: (value) async {
                    selectedApprovalStatus = value;
                    await loadQuestions();
                  },
                ),
                if (role == 'teacher') ...[
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Đang hiển thị các câu hỏi do bạn tạo.',
                      style: TextStyle(color: AppTheme.subText),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (_, index) {
                          final q = questions[index];
                          final approvalStatus =
                              (q['approval_status'] ?? 'approved').toString();
                          final difficulty =
                              (q['difficulty'] ?? 'medium').toString();
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
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Part ${q['part']} - ${q['content']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.text,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _badge(
                                            label: difficulty.toUpperCase(),
                                            color: _difficultyColor(difficulty),
                                          ),
                                          _badge(
                                            label: approvalStatus.toUpperCase(),
                                            color: _statusColor(approvalStatus),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'A. ${q['option_a']}\n'
                                    'B. ${q['option_b']}\n'
                                    'Đáp án: ${q['correct_answer']}',
                                    style: const TextStyle(
                                      color: AppTheme.subText,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      if ((q['audio_url'] ?? '').toString().isNotEmpty)
                                        const Icon(
                                          Icons.audiotrack_rounded,
                                          color: AppTheme.primary,
                                        ),
                                      if ((q['audio_url'] ?? '').toString().isNotEmpty)
                                        const SizedBox(width: 8),
                                      if ((q['image_url'] ?? '').toString().isNotEmpty)
                                        const Icon(
                                          Icons.image_outlined,
                                          color: AppTheme.secondary,
                                        ),
                                      const Spacer(),
                                      if (canApprove && approvalStatus != 'approved')
                                        IconButton(
                                          onPressed: () => changeApproval(
                                            _toInt(q['id']),
                                            'approved',
                                          ),
                                          icon: const Icon(
                                            Icons.verified_rounded,
                                            color: Colors.green,
                                          ),
                                        ),
                                      if (canApprove && approvalStatus != 'rejected')
                                        IconButton(
                                          onPressed: () => changeApproval(
                                            _toInt(q['id']),
                                            'rejected',
                                          ),
                                          icon: const Icon(
                                            Icons.cancel_outlined,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      if (canEdit)
                                        IconButton(
                                          onPressed: () => _openQuestionForm(
                                            question: q,
                                          ),
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      if (canDelete)
                                        IconButton(
                                          onPressed: () => deleteQuestion(_toInt(q['id'])),
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
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
