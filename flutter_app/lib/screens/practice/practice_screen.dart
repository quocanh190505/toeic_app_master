import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/constants/api_constants.dart';
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
  static const Map<int, int> _fullTestGroupSize = {
    1: 1,
    2: 1,
    3: 3,
    4: 3,
    5: 1,
    6: 2,
    7: 3,
  };

  final TestService service = TestService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<QuestionModel> questions = [];
  List<_QuestionUnit> fullTestUnits = [];
  final Map<int, String> selectedAnswers = {};
  final Set<int> bookmarked = {};

  Timer? _timer;
  Duration _remainingTime = _fullTestDuration;
  bool _timeExpired = false;
  String? _activeAudioUrl;

  bool loading = true;
  bool submitting = false;
  String? error;
  int _currentUnitIndex = 0;

  bool get _isFullTest => widget.testType == 'full';
  bool get _isStructuredPractice => _isFullTest || widget.part != null;
  bool get _hasUnits => _isStructuredPractice && fullTestUnits.isNotEmpty;

  _QuestionUnit? get _currentUnit {
    if (!_hasUnits) return null;
    return fullTestUnits[_currentUnitIndex];
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed ||
          (!state.playing && _activeAudioUrl != null)) {
        setState(() => _activeAudioUrl = null);
      }
    });
    loadQuestions();
  }

  @override
  void dispose() {
    _stopTimer();
    _audioPlayer.dispose();
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
        fullTestUnits = [];
        selectedAnswers.clear();
        _currentUnitIndex = 0;
        _timeExpired = false;
        _activeAudioUrl = null;
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
        fullTestUnits = _isStructuredPractice ? _buildFullTestUnits(data) : [];
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

  List<_QuestionUnit> _buildFullTestUnits(List<QuestionModel> data) {
    final units = <_QuestionUnit>[];

    for (final part in _fullTestGroupSize.keys) {
      final partQuestions =
          data.where((question) => question.part == part).toList()
            ..sort((a, b) {
              final orderCompare = a.questionOrder.compareTo(b.questionOrder);
              if (orderCompare != 0) return orderCompare;
              return a.id.compareTo(b.id);
            });

      final groupedByKey = <String, List<QuestionModel>>{};
      final ungrouped = <QuestionModel>[];
      for (final question in partQuestions) {
        final key = question.groupKey?.trim();
        if (key != null && key.isNotEmpty) {
          groupedByKey.putIfAbsent(key, () => []).add(question);
        } else {
          ungrouped.add(question);
        }
      }

      if (groupedByKey.isNotEmpty) {
        final partUnits = <_QuestionUnit>[];
        final sortedKeys = groupedByKey.keys.toList()
          ..sort((a, b) {
            final firstA = groupedByKey[a]!.first;
            final firstB = groupedByKey[b]!.first;
            final orderCompare =
                firstA.questionOrder.compareTo(firstB.questionOrder);
            if (orderCompare != 0) return orderCompare;
            return firstA.id.compareTo(firstB.id);
          });

        for (final key in sortedKeys) {
          final groupedQuestions = groupedByKey[key]!
            ..sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
          final section = groupedQuestions.first.section ??
              (part <= 4 ? 'listening' : 'reading');
          partUnits.add(
            _QuestionUnit(
              section: section,
              sectionTitle: section == 'reading' ? 'Bài đọc' : 'Bài nghe',
              part: part,
              questions: groupedQuestions,
            ),
          );
        }

        for (final question in ungrouped) {
          final section =
              question.section ?? (part <= 4 ? 'listening' : 'reading');
          partUnits.add(
            _QuestionUnit(
              section: section,
              sectionTitle: section == 'reading' ? 'Bài đọc' : 'Bài nghe',
              part: part,
              questions: [question],
            ),
          );
        }

        partUnits.sort(
          (a, b) => a.questions.first.id.compareTo(b.questions.first.id),
        );
        units.addAll(partUnits);
        continue;
      }

      final chunkSize = _fullTestGroupSize[part]!;
      for (var index = 0; index < partQuestions.length; index += chunkSize) {
        final end = index + chunkSize;
        if (end > partQuestions.length) break;

        units.add(
          _QuestionUnit(
            section: part <= 4 ? 'listening' : 'reading',
            sectionTitle: part <= 4 ? 'Bài nghe' : 'Bài đọc',
            part: part,
            questions: partQuestions.sublist(index, end),
          ),
        );
      }
    }

    return units;
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
    if (_isStructuredPractice) {
      final unansweredCount = questions.length - selectedAnswers.length;
      if (unansweredCount > 0) {
        final confirmed = await _confirmIncompleteSubmission(unansweredCount);
        if (confirmed != true) return;
        await _submitInternal(allowIncomplete: true);
        return;
      }
    }

    await _submitInternal();
  }

  Future<void> _toggleAudio(String rawUrl) async {
    final resolvedUrl = ApiConstants.uploadUrl(rawUrl);

    try {
      if (_activeAudioUrl == resolvedUrl && _audioPlayer.playing) {
        await _audioPlayer.pause();
        if (mounted) {
          setState(() => _activeAudioUrl = null);
        }
        return;
      }

      await _audioPlayer.stop();
      await _audioPlayer.setUrl(resolvedUrl);
      await _audioPlayer.play();

      if (!mounted) return;
      setState(() => _activeAudioUrl = resolvedUrl);
    } catch (e) {
      if (!mounted) return;
      setState(() => _activeAudioUrl = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không phát được audio: $e')),
      );
    }
  }

  Future<bool?> _confirmIncompleteSubmission(int unansweredCount) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận nộp bài'),
          content: Text(
            'Bài làm chưa hoàn thành, bạn có chắc chắn nộp bài không?\n\n'
            'Bạn còn $unansweredCount câu chưa trả lời.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tiếp tục làm bài'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Nộp bài'),
            ),
          ],
        );
      },
    );
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
      error =
          autoSubmitted ? 'Đã hết giờ. Hệ thống đang tự động nộp bài...' : null;
    });

    _stopTimer();

    try {
      final answers = questions
          .map(
            (q) => {
              'question_id': q.id,
              'selected_answer': selectedAnswers[q.id],
            },
          )
          .toList();

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

  bool _isUnitAnswered(_QuestionUnit unit) {
    return unit.questions
        .every((question) => selectedAnswers.containsKey(question.id));
  }

  void _goToPreviousUnit() {
    if (!_hasUnits || _currentUnitIndex == 0) return;
    setState(() {
      error = null;
      _currentUnitIndex -= 1;
    });
  }

  void _goToNextUnit() {
    final unit = _currentUnit;
    if (unit == null) return;

    if (_currentUnitIndex >= fullTestUnits.length - 1) {
      submit();
      return;
    }

    setState(() {
      error = !_isUnitAnswered(unit)
          ? 'Cụm hiện tại chưa hoàn thành. Bạn vẫn có thể tiếp tục hoặc nộp bài bất kỳ lúc nào.'
          : null;
      _currentUnitIndex += 1;
    });
  }

  Widget buildOption(QuestionModel q, String key) {
    final value = (q.options[key] ?? '').toString();

    if (value.isEmpty && q.part != 2) return const SizedBox.shrink();

    final hidesOptionText = q.part == 1 || q.part == 2;
    final optionLabel = hidesOptionText ? key : '$key. $value';

    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      title: Text(optionLabel),
      value: key,
      groupValue: selectedAnswers[q.id],
      onChanged: _timeExpired
          ? null
          : (v) {
              if (v == null) return;
              setState(() {
                selectedAnswers[q.id] = v;
                error = null;
              });
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
    if (_isStructuredPractice && _currentUnit != null) {
      final unit = _currentUnit!;
      final answeredInUnit = unit.questions
          .where((question) => selectedAnswers.containsKey(question.id))
          .length;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isFullTest ? 'Full Test' : 'Mini Test',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${unit.sectionTitle} - Part ${unit.part}',
              style: const TextStyle(color: AppTheme.subText),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InfoChip(
                  label: 'Cụm',
                  value: '${_currentUnitIndex + 1}/${fullTestUnits.length}',
                ),
                _InfoChip(
                  label: 'Trong cụm',
                  value: '$answeredInUnit/${unit.questions.length}',
                ),
                _InfoChip(
                  label: 'Tổng tiến độ',
                  value: '${selectedAnswers.length}/${questions.length}',
                ),
                if (_isFullTest) _buildTimerChip(),
              ],
            ),
          ],
        ),
      );
    }

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
            children: [
              Text(
                'Tổng số câu: ${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Đã chọn: ${selectedAnswers.length}/${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSharedMedia(_QuestionUnit unit) {
    final sharedImageUrl = unit.questions
        .map((question) => question.sharedImageUrl?.trim() ?? '')
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    final sharedAudioUrl = unit.questions
        .map((question) => question.sharedAudioUrl?.trim() ?? '')
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    final imageQuestion = unit.questions.firstWhere(
      (question) =>
          question.imageUrl != null && question.imageUrl!.trim().isNotEmpty,
      orElse: () => unit.questions.first,
    );
    final audioQuestion = unit.questions.firstWhere(
      (question) =>
          question.audioUrl != null && question.audioUrl!.trim().isNotEmpty,
      orElse: () => unit.questions.first,
    );

    final hasSharedImage = sharedImageUrl.isNotEmpty;
    final hasSharedAudio = sharedAudioUrl.isNotEmpty;
    final hasImage = hasSharedImage ||
        (imageQuestion.imageUrl != null &&
            imageQuestion.imageUrl!.trim().isNotEmpty);
    final hasAudio = hasSharedAudio ||
        (audioQuestion.audioUrl != null &&
            audioQuestion.audioUrl!.trim().isNotEmpty);
    final sharedContent = unit.questions
        .map((question) => question.sharedContent?.trim() ?? '')
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    final showSharedText = sharedContent.isNotEmpty && unit.part >= 6;

    if (!hasImage && !hasAudio && !showSharedText) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unit.part <= 4 ? 'Tư liệu nghe / nhìn' : 'Tư liệu đọc',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.text,
            ),
          ),
          if (showSharedText) ...[
            const SizedBox(height: 10),
            Text(
              sharedContent,
              style: const TextStyle(
                color: AppTheme.text,
                height: 1.5,
              ),
            ),
          ],
          if (hasImage) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                ApiConstants.uploadUrl(
                  hasSharedImage ? sharedImageUrl : imageQuestion.imageUrl,
                ),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: const Color(0xFFE2E8F0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Không tải được hình ảnh',
                      style: TextStyle(color: AppTheme.subText),
                    ),
                  );
                },
              ),
            ),
          ],
          if (hasAudio) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _toggleAudio(
                hasSharedAudio ? sharedAudioUrl : audioQuestion.audioUrl!,
              ),
              icon: Icon(
                _activeAudioUrl ==
                            ApiConstants.uploadUrl(
                              hasSharedAudio
                                  ? sharedAudioUrl
                                  : audioQuestion.audioUrl,
                            ) &&
                        _audioPlayer.playing
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
              ),
              label: Text(
                _activeAudioUrl ==
                            ApiConstants.uploadUrl(
                              hasSharedAudio
                                  ? sharedAudioUrl
                                  : audioQuestion.audioUrl,
                            ) &&
                        _audioPlayer.playing
                    ? 'Tạm dừng audio'
                    : 'Nghe audio',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    QuestionModel question, {
    required int displayNumber,
    bool showOwnMedia = true,
  }) {
    final hidesQuestionText = question.part == 2;
    final hasImage =
        question.imageUrl != null && question.imageUrl!.trim().isNotEmpty;
    final hasAudio =
        question.audioUrl != null && question.audioUrl!.trim().isNotEmpty;

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
                    'Câu $displayNumber - Part ${question.part}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => toggleBookmark(question.id),
                  icon: Icon(
                    bookmarked.contains(question.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: bookmarked.contains(question.id)
                        ? AppTheme.secondary
                        : null,
                  ),
                ),
              ],
            ),
            if (!hidesQuestionText) ...[
              const SizedBox(height: 10),
              Text(
                question.content,
                style: const TextStyle(fontSize: 15),
              ),
            ],
            if (showOwnMedia && (hasImage || hasAudio)) ...[
              const SizedBox(height: 12),
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    ApiConstants.uploadUrl(question.imageUrl),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            'Không tải được hình ảnh',
                            style: TextStyle(color: AppTheme.subText),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (hasImage) const SizedBox(height: 12),
              if (hasAudio)
                OutlinedButton.icon(
                  onPressed: () => _toggleAudio(question.audioUrl!),
                  icon: Icon(
                    _activeAudioUrl ==
                                ApiConstants.uploadUrl(question.audioUrl) &&
                            _audioPlayer.playing
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                  ),
                  label: Text(
                    _activeAudioUrl ==
                                ApiConstants.uploadUrl(question.audioUrl) &&
                            _audioPlayer.playing
                        ? 'Tạm dừng audio'
                        : 'Nghe audio',
                  ),
                ),
            ],
            buildOption(question, 'A'),
            buildOption(question, 'B'),
            buildOption(question, 'C'),
            buildOption(question, 'D'),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuredBody() {
    final unit = _currentUnit;
    if (unit == null) {
      return const Center(child: Text('Không có dữ liệu full test.'));
    }

    final firstQuestionIndex =
        questions.indexWhere((item) => item.id == unit.questions.first.id);
    final baseDisplayNumber =
        firstQuestionIndex >= 0 ? firstQuestionIndex + 1 : 1;
    final useSharedMedia = unit.questions.length > 1;

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: unit.section == 'listening'
                        ? const [Color(0xFFE0F2FE), Color(0xFFF8FAFC)]
                        : const [Color(0xFFFFF7ED), Color(0xFFFFFBEB)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.sectionTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      unit.questions.first.instructions?.trim().isNotEmpty ==
                              true
                          ? unit.questions.first.instructions!
                          : _instructionForPart(unit.part),
                      style: const TextStyle(
                        color: AppTheme.subText,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (useSharedMedia) _buildSharedMedia(unit),
              ...unit.questions.asMap().entries.map((entry) {
                final localIndex = entry.key;
                final question = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: localIndex == unit.questions.length - 1 ? 0 : 14,
                  ),
                  child: _buildQuestionCard(
                    question,
                    displayNumber: baseDisplayNumber + localIndex,
                    showOwnMedia: !useSharedMedia,
                  ),
                );
              }),
            ],
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _currentUnitIndex == 0 || submitting || _timeExpired
                          ? null
                          : _goToPreviousUnit,
                  child: const Text('Quay lại'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: submitting || _timeExpired ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _isFullTest ? 'Nộp Full Test' : 'Nộp Mini Test',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: submitting || _timeExpired ? null : _goToNextUnit,
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
                          _currentUnitIndex == fullTestUnits.length - 1
                              ? 'Hoàn thành'
                              : 'Tiếp theo',
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _instructionForPart(int part) {
    switch (part) {
      case 1:
        return 'Part 1: Mỗi trang gồm 1 câu với ảnh và lựa chọn mô tả đúng nhất.';
      case 2:
        return 'Part 2: Mỗi trang gồm 1 câu hỏi nghe ngắn và 4 lựa chọn trả lời.';
      case 3:
        return 'Part 3: Mỗi cụm gồm 1 đoạn hội thoại và 3 câu hỏi liên tiếp.';
      case 4:
        return 'Part 4: Mỗi cụm gồm 1 bài nói ngắn và 3 câu hỏi liên tiếp.';
      case 5:
        return 'Part 5: Mỗi trang là 1 câu hỏi ngữ pháp hoặc từ vựng độc lập.';
      case 6:
        return 'Part 6: Mỗi cụm gồm 1 đoạn văn ngắn và 2 câu hỏi liên quan.';
      case 7:
        return 'Part 7: Mỗi cụm gồm 1 bài đọc và 3 câu hỏi đi kèm.';
      default:
        return 'Làm bài theo đúng thứ tự của đề thi.';
    }
  }

  Widget _buildDefaultBody() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final question = questions[index];
              return _buildQuestionCard(
                question,
                displayNumber: index + 1,
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
          if (_isStructuredPractice)
            IconButton(
              onPressed: submitting || _timeExpired ? null : submit,
              icon: const Icon(Icons.send_rounded),
              tooltip: _isFullTest ? 'Nộp Full Test' : 'Nộp Mini Test',
            ),
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
          : (_isStructuredPractice
              ? _buildStructuredBody()
              : _buildDefaultBody()),
    );
  }
}

class _QuestionUnit {
  final String section;
  final String sectionTitle;
  final int part;
  final List<QuestionModel> questions;

  const _QuestionUnit({
    required this.section,
    required this.sectionTitle,
    required this.part,
    required this.questions,
  });
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(
                color: AppTheme.text,
              ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
