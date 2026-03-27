import 'package:flutter/material.dart';
import '../../services/test_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/question_model.dart';
import 'result_screen.dart';

class PracticeScreen extends StatefulWidget {
  final String testType;
  final int? part;

  const PracticeScreen({
    super.key,
    required this.testType,
    this.part,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final TestService service = TestService();

  List<QuestionModel> questions = [];
  final Map<int, String> selectedAnswers = {};
  final Set<int> bookmarked = {};

  bool loading = true;
  bool submitting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
        questions = [];
        selectedAnswers.clear();
      });
    }

    try {
      List<QuestionModel> data = [];

      if (widget.testType == 'full') {
        data = await service.getFullTest();
      } else {
        // Đã sửa lỗi null safety ở đây
        if (widget.part != null) {
          data = await service.getMiniTest(part: widget.part!);
        } else {
          // Nếu không truyền part (Mini test ngẫu nhiên), tải 30 câu ngẫu nhiên
          data = await service.getQuestions(randomMode: true, limit: 30);
        }
      }

      if (!mounted) return;

      setState(() {
        questions = data;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> toggleBookmark(int questionId) async {
    try {
      if (bookmarked.contains(questionId)) {
        await service.unbookmarkQuestion(questionId);
        bookmarked.remove(questionId);
      } else {
        await service.bookmarkQuestion(questionId);
        bookmarked.add(questionId);
      }

      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> submit() async {
    if (questions.isEmpty) {
      setState(() {
        error = 'Không có câu hỏi để nộp bài';
      });
      return;
    }

    if (selectedAnswers.length < questions.length) {
      setState(() {
        error = 'Bạn chưa trả lời hết tất cả câu hỏi';
      });
      return;
    }

    setState(() {
      submitting = true;
      error = null;
    });

    try {
      final answers = questions.map((q) {
        return {
          'question_id': q.id,
          'selected_answer': selectedAnswers[q.id],
        };
      }).toList();

      final result = await service.submit(
        testType: widget.testType,
        answers: answers,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(resultData: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;

      setState(() {
        submitting = false;
      });
    }
  }

  Widget buildOption(QuestionModel q, String key) {
    final value = (q.options[key] ?? '').toString();

    if (value.isEmpty) return const SizedBox.shrink();

    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      title: Text('$key. $value'),
      value: key,
      groupValue: selectedAnswers[q.id],
      onChanged: (v) {
        if (v != null) {
          setState(() {
            selectedAnswers[q.id] = v;
            error = null;
          });
        }
      },
    );
  }

  Widget _buildHeader() {
    final title = widget.testType == 'full' ? 'Full Test' : 'Mini Test';
    final subtitle = widget.testType == 'full'
        ? 'Bài test đầy đủ'
        : widget.part != null
            ? 'Mini Test - Part ${widget.part}'
            : 'Mini Test ngẫu nhiên';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.subText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng số câu: ${questions.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
      appBar: AppBar(
        title: Text(widget.testType == 'full' ? 'Full Test' : 'Mini Test'),
        actions: [
          IconButton(
            onPressed: loadQuestions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: questions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  error ?? 'Không tải được câu hỏi',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final q = questions[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Câu ${index + 1} · Part ${q.part}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => toggleBookmark(q.id),
                                    icon: Icon(
                                      bookmarked.contains(q.id)
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: bookmarked.contains(q.id)
                                          ? AppTheme.secondary
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                q.content,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 12),
                              buildOption(q, 'A'),
                              buildOption(q, 'B'),
                              buildOption(q, 'C'),
                              buildOption(q, 'D'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      error!,
                      style: const TextStyle(color: AppTheme.danger),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: submitting ? null : submit,
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.testType == 'full'
                                ? 'Nộp Full Test'
                                : 'Nộp Mini Test',
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}