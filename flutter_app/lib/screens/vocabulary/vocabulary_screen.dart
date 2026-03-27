import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../core/theme/app_theme.dart';
import 'package:dio/dio.dart';

// --- MÀN HÌNH 1: DANH SÁCH CHỦ ĐỀ (TOPICS) ---
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final Dio _dio = ApiClient().dio;
  List<dynamic> topics = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
  try {
    // Sửa từ '/topics' thành '/vocabulary/topics'
    final response = await _dio.get('/vocabulary/topics'); 
    setState(() {
      topics = response.data;
      loading = false;
    });
  } catch (e) {
    // ... giữ nguyên code cũ
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chủ đề từ vựng')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchTopics,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return _buildTopicCard(topic);
                },
              ),
            ),
    );
  }

  Widget _buildTopicCard(dynamic topic) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WordListScreen(
              topicId: topic['id'],
              topicName: topic['name'],
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style, size: 50, color: AppTheme.primary),
            const SizedBox(height: 12),
            Text(
              topic['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              topic['description'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// --- MÀN HÌNH 2: DANH SÁCH TỪ VỰNG THEO CHỦ ĐỀ ---
class WordListScreen extends StatefulWidget {
  final int topicId;
  final String topicName;

  const WordListScreen({super.key, required this.topicId, required this.topicName});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final Dio _dio = ApiClient().dio;
  List<dynamic> words = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWords();
  }

  Future<void> _fetchWords() async {
  try {
 
    final response = await _dio.get('/vocabulary', queryParameters: {'topic_id': widget.topicId});
    setState(() {
      words = response.data;
      loading = false;
    });
  } catch (e) {
    setState(() => loading = false);
  }
}

  Future<void> _markAsStudied(int wordId, int index) async {
    try {
      await _dio.post('/vocabulary/$wordId/study');
      setState(() {
        words[index]['is_studied'] = true;
      });
      // Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thuộc từ này!'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      print('Lỗi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicName)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: words.length,
              itemBuilder: (context, index) {
                final w = words[index];
                final isStudied = w['is_studied'] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(w['word'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nghĩa: ${w['meaning']}', style: const TextStyle(color: AppTheme.primary)),
                        if (w['example'] != null)
                          Text('VD: ${w['example']}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isStudied ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isStudied ? Colors.green : Colors.grey,
                      ),
                      onPressed: isStudied ? null : () => _markAsStudied(w['id'], index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}