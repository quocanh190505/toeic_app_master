import 'package:flutter/material.dart';

import '../../services/app_data_service.dart';
import '../../models/vocabulary_word_model.dart';
import '../../core/theme/app_theme.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final service = AppDataService();
  List<VocabularyWordModel> words = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    words = await service.getVocabulary();
    setState(() => loading = false);
  }

  Future<void> study(int id) async {
    await service.studyWord(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu từ đã học')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Từ vựng TOEIC')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: words.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = words[index];
          return Card(
            child: ListTile(
              title: Text(
                item.word,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${item.meaning}\n${item.example ?? ''}',
              ),
              trailing: IconButton(
                onPressed: () => study(item.id),
                icon: const Icon(Icons.check_circle_outline, color: AppTheme.primary),
              ),
            ),
          );
        },
      ),
    );
  }
}