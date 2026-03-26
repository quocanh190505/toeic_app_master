import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/question_model.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../services/progress_service.dart';
import '../../services/question_service.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final QuestionService _questionService = QuestionService();

  bool _loading = true;
  String? _error;
  List<QuestionModel> _questions = [];
  int? _selectedIndex;
  int? _selectedOptionIndex;
  bool _submitted = false;

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
        if (_questions.isNotEmpty) {
          _selectedIndex = 0;
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Không tải được câu hỏi';
      });
    }
  }

  Future<void> _submitAnswer() async {
    final userId = context.read<AuthService>().userId;
    if (userId == null || _selectedIndex == null || _selectedOptionIndex == null) {
      return;
    }

    setState(() {
      _submitted = true;
    });

    await context.read<ProgressService>().saveStudyProgress(userId);
  }

  @override
  Widget build(BuildContext context) {
    final audioService = context.read<AudioService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập TOEIC')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _questions.isEmpty
                  ? const Center(child: Text('Chưa có câu hỏi'))
                  : Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.grey.shade100,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: _questions.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final q = _questions[index];
                                final selected = index == _selectedIndex;

                                return ListTile(
                                  tileColor: selected ? Colors.blue.shade50 : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Text('Câu ${index + 1} - Part ${q.part}'),
                                  subtitle: Text(
                                    q.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                      _selectedOptionIndex = null;
                                      _submitted = false;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _buildQuestionDetail(audioService),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildQuestionDetail(AudioService audioService) {
    if (_selectedIndex == null) {
      return const Center(child: Text('Chọn một câu hỏi'));
    }

    final question = _questions[_selectedIndex!];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              'Part ${question.part}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question.content,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (question.audioUrl != null && question.audioUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FilledButton.icon(
                  onPressed: () async {
                    await audioService.playUrl(question.audioUrl!);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Phát audio'),
                ),
              ),
            ...List.generate(question.options.length, (index) {
              return RadioListTile<int>(
                value: index,
                groupValue: _selectedOptionIndex,
                onChanged: _submitted
                    ? null
                    : (value) {
                        setState(() {
                          _selectedOptionIndex = value;
                        });
                      },
                title: Text(question.options[index]),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_submitted || _selectedOptionIndex == null)
                    ? null
                    : _submitAnswer,
                child: const Text('Nộp đáp án'),
              ),
            ),
            if (_submitted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  question.explanation ?? 'Chưa có giải thích cho câu này.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}