import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/question_model.dart';
import '../../services/test_service.dart';
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
  static const Duration _fullTestDuration = Duration(hours: 2);

  final TestService service = TestService();

  List<QuestionModel> questions = [];
  final Map<int, String> selectedAnswers = {};
  final Set<int> bookmarked = {};

  Timer? _timer;
  Duration _remainingTime = _fullTestDuration;
  bool _timeExpired = false;

  bool loading = true;
  bool submitting = false;
  String? error;

  bool get _isFullTest => widget.testType == 'full';

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startFullTestTimer() {
    _stopTimer();

    if (!_isFullTest || questions.isEmpty) return;

    _remainingTime = _fullTestDuration;
    _timeExpired = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingTime.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingTime = Duration.zero;
          _timeExpired = true;
        });
        _submitInternal(allowIncomplete: true, autoSubmitted: true);
        return;
      }

      setState(() {
        _remainingTime -= const Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> loadQuestions() async {
    _stopTimer();

    if (mounted) {
      setState(() {
        loading = true;
        error = null;
        questions = [];
        selectedAnswers.clear();
        _timeExpired = false;
        if (_isFullTest) {
          _remainingTime = _fullTestDuration;
        }
      });
    }

    try {
      List<QuestionModel> data = [];

      if (_isFullTest) {
        data = await service.getFullTest();
      } else if (widget.part != null) {
        data = await service.getMiniTest(part: widget.part!);
      } else {
        data = await service.getQuestions(randomMode: true, limit: 30);
      }

      if (!mounted) return;

      setState(() {
        questions = data;
      });

      _startFullTestTimer();
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
    await _submitInternal();
  }

  Future<void> _submitInternal({
    bool allowIncomplete = false,
    bool autoSubmitted = false,
  }) async {
    if (questions.isEmpty) {
      setState(() {
        error = 'Không có câu hỏi để nộp bài.';
      });
      return;
    }

    if (submitting) return;

    if (!allowIncomplete && selectedAnswers.length < questions.length) {
      setState(() {
        error = 'Bạn chưa trả lời hết tất cả câu hỏi.';
      });
      return;
    }

    setState(() {
      submitting = true;
      error = autoSubmitted
          ? 'Đã hết giờ. Hệ thống đang tự động nộp bài...'
          : null;
    });

    _stopTimer();

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
      onChanged: _timeExpired
          ? null
          : (v) {
              if (v != null) {
                setState(() {
                  selectedAnswers[q.id] = v;
                  error = null;
                });
              }
            },
    );
  }

  Widget _buildTimerChip() {
    final warning = _remainingTime.inMinutes < 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: warning
            ? AppTheme.danger.withOpacity(0.12)
            : AppTheme.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: warning ? AppTheme.danger : AppTheme.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            _formatDuration(_remainingTime),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: warning ? AppTheme.danger : AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final title = _isFullTest ? 'Full Test' : 'Mini Test';
    final subtitle = _isFullTest
        ? 'Mô phỏng bài thi TOEIC đầy đủ'
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
            style: const TextStyle(color: AppTheme.subText),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Tổng số câu: ${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Đã chọn: ${selectedAnswers.length}/${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (_isFullTest) _buildTimerChip(),
            ],
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
        title: Text(_isFullTest ? 'Full Test' : 'Mini Test'),
        actions: [
          if (_isFullTest)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildTimerChip(),
            ),
          IconButton(
            onPressed: submitting ? null : loadQuestions,
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
                  error ?? 'Không tải được câu hỏi.',
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
                    onPressed: submitting || _timeExpired ? null : submit,
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
                            _isFullTest ? 'Nộp Full Test' : 'Nộp Mini Test',
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
