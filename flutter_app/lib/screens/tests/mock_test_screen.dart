import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/question_model.dart';
import '../../services/auth_service.dart';
import '../../services/progress_service.dart';
import '../../services/question_service.dart';

class MockTestScreen extends StatefulWidget {
  const MockTestScreen({super.key});

  @override
  State<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  final QuestionService _questionService = QuestionService();

  bool _loading = true;
  String? _error;
  List<QuestionModel> _questions = [];

  int currentIndex = 0;
  int? selected;
  bool submitted = false;
  int correctCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _questionService.getQuestions();

      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      debugPrint('MockTest load error: $e');
      setState(() {
        _loading = false;
        _error = 'Không tải được bài test';
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_questions.isEmpty || selected == null || submitted) return;

    final currentQuestion = _questions[currentIndex];
    final correctIndex = _getCorrectIndex(currentQuestion.correctAnswer);

    setState(() {
      submitted = true;
      if (selected == correctIndex) {
        correctCount += 1;
      }
    });

    final userId = context.read<AuthService>().userId;
    if (userId != null) {
      await context.read<ProgressService>().saveTestCompletion(userId);
    }
  }

  void _nextQuestion() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex += 1;
        selected = null;
        submitted = false;
      });
    } else {
      _showFinishedDialog();
    }
  }

  void _retryCurrent() {
    setState(() {
      selected = null;
      submitted = false;
    });
  }

  int _getCorrectIndex(String answer) {
    switch (answer.trim().toUpperCase()) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return -1;
    }
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hoàn thành bài test'),
        content: Text(
          'Bạn làm đúng $correctCount / ${_questions.length} câu.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Về trang chủ'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentIndex = 0;
                selected = null;
                submitted = false;
                correctCount = 0;
              });
            },
            child: const Text('Làm lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mock Test')),
        body: Center(child: Text(_error!)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mock Test')),
        body: const Center(child: Text('Chưa có câu hỏi trong database')),
      );
    }

    final question = _questions[currentIndex];
    final correctIndex = _getCorrectIndex(question.correctAnswer);
    final explanationText = question.explanation ?? '';
    final resultText = selected == correctIndex
        ? 'Chính xác. $explanationText'
        : 'Đáp án đúng là ${question.correctAnswer}. $explanationText';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu ${currentIndex + 1}/${_questions.length} - Part ${question.part}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 18),
                Text(question.content),
                const SizedBox(height: 12),
                ...List.generate(question.options.length, (index) {
                  return RadioListTile<int>(
                    value: index,
                    groupValue: selected,
                    onChanged: submitted
                        ? null
                        : (value) => setState(() => selected = value),
                    title: Text(question.options[index]),
                  );
                }),
                const SizedBox(height: 16),
                if (submitted)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected == correctIndex
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(resultText),
                  ),
                const Spacer(),
                if (!submitted)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: selected == null ? null : _submitAnswer,
                      child: const Text('Nộp bài'),
                    ),
                  ),
                if (submitted)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _retryCurrent,
                          child: const Text('Làm lại câu này'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _nextQuestion,
                          child: Text(
                            currentIndex == _questions.length - 1
                                ? 'Hoàn thành'
                                : 'Câu tiếp theo',
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}