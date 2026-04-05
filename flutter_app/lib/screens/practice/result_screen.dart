import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultScreen({super.key, required this.resultData});

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  List<Map<String, dynamic>> _toListMap(dynamic value) {
    if (value is List) {
      return value
          .map(
            (e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{},
          )
          .toList();
    }
    return [];
  }

  String _formatPercent(dynamic value) {
    final number = _toDouble(value);
    if (number <= 1) return '${(number * 100).toStringAsFixed(1)}%';
    return '${number.toStringAsFixed(1)}%';
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 26),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.subText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _partStatTile(String partKey, Map<String, dynamic> value) {
    final total = _toInt(value['total']);
    final correct = _toInt(value['correct']);
    final accuracy = _toDouble(value['accuracy']);

    return Card(
      child: ListTile(
        title: Text(
          'Part $partKey',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'Dung: $correct/$total\nChinh xac: ${accuracy.toStringAsFixed(2)}%',
        ),
      ),
    );
  }

  Widget _resultTile(Map<String, dynamic> item, int index) {
    final isCorrect = item['is_correct'] == true;
    final part = _toInt(item['part']);
    final hidesPart2Content = part == 2;
    final content = hidesPart2Content
        ? 'Cau ${index + 1} - Part 2'
        : (item['content'] ?? 'Cau hoi ${index + 1}').toString();
    final selectedAnswer = (item['selected_answer'] ?? 'Chua chon').toString();
    final correctAnswer = (item['correct_answer'] ?? '').toString();
    final explanation = (item['explanation'] ?? '').toString();
    final explanationLabel = hidesPart2Content
        ? 'An cho Part 2'
        : (explanation.isEmpty ? 'Khong co' : explanation);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          content,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Ban chon: $selectedAnswer\n'
            'Dap an dung: $correctAnswer\n'
            'Giai thich: $explanationLabel',
          ),
        ),
        trailing: Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? Colors.green : AppTheme.danger,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _toListMap(resultData['results']);
    final progress = _toMap(resultData['progress']);
    final partStatsRaw = _toMap(resultData['part_stats']);

    final score = _toInt(resultData['score']);
    final correctCount = _toInt(resultData['correct_count']);
    final totalQuestions = _toInt(resultData['total_questions']);

    final completedTests = _toInt(progress['completed_tests']);
    final overallProgress = progress.containsKey('overall_progress')
        ? _formatPercent(progress['overall_progress'])
        : '0.0%';
    final highestScore = _toInt(progress['highest_score']);

    final sortedPartKeys = partStatsRaw.keys.toList()
      ..sort((a, b) {
        final aNum = int.tryParse(a.toString()) ?? 0;
        final bNum = int.tryParse(b.toString()) ?? 0;
        return aNum.compareTo(bNum);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ket qua'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dung $correctCount/$totalQuestions cau',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'Bai da hoan thanh',
                  value: '$completedTests',
                  icon: Icons.assignment_turned_in_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  title: 'Diem cao nhat',
                  value: '$highestScore',
                  icon: Icons.emoji_events_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryCard(
            title: 'Tien do tong',
            value: overallProgress,
            icon: Icons.show_chart,
          ),
          const SizedBox(height: 20),
          const Text(
            'Thong ke theo part',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (sortedPartKeys.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chua co thong ke theo part'),
              ),
            )
          else
            ...sortedPartKeys.map((key) {
              final value = _toMap(partStatsRaw[key]);
              return _partStatTile(key.toString(), value);
            }),
          const SizedBox(height: 20),
          const Text(
            'Dap an chi tiet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (results.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chua co du lieu dap an chi tiet'),
              ),
            )
          else
            ...results.asMap().entries.map(
              (entry) => _resultTile(entry.value, entry.key),
            ),
        ],
      ),
    );
  }
}
