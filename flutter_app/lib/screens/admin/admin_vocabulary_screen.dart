import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../services/api_client.dart';

class AdminVocabularyScreen extends StatefulWidget {
  final int topicId;
  final String topicName;

  const AdminVocabularyScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<AdminVocabularyScreen> createState() => _AdminVocabularyScreenState();
}

class _AdminVocabularyScreenState extends State<AdminVocabularyScreen> {
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
      final response = await _dio.get(
        '/vocabulary',
        queryParameters: {'topic_id': widget.topicId},
      );
      setState(() {
        words = response.data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _deleteWord(int id) async {
    try {
      await _dio.delete('/admin/vocabulary/$id');
      _fetchWords();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa từ vựng.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa từ vựng thất bại.')),
      );
    }
  }

  void _showWordForm({dynamic word}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.9,
        child: _WordFormBottomSheet(
          topicId: widget.topicId,
          wordData: word,
          onSaved: () {
            Navigator.pop(sheetContext);
            setState(() => loading = true);
            _fetchWords();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Từ vựng: ${widget.topicName}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWordForm(),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: words.length,
              itemBuilder: (context, index) {
                final w = words[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      w['word'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Nghĩa: ${w['meaning']}\nVí dụ: ${w['example'] ?? 'Không có'}',
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showWordForm(word: w),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteWord(w['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _WordFormBottomSheet extends StatefulWidget {
  final int topicId;
  final dynamic wordData;
  final VoidCallback onSaved;

  const _WordFormBottomSheet({
    required this.topicId,
    this.wordData,
    required this.onSaved,
  });

  @override
  State<_WordFormBottomSheet> createState() => _WordFormBottomSheetState();
}

class _WordFormBottomSheetState extends State<_WordFormBottomSheet> {
  final _wordCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _exampleCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.wordData != null) {
      _wordCtrl.text = widget.wordData['word'];
      _meaningCtrl.text = widget.wordData['meaning'];
      _exampleCtrl.text = widget.wordData['example'] ?? '';
    }
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _exampleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_wordCtrl.text.trim().isEmpty || _meaningCtrl.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payload = {
        'word': _wordCtrl.text.trim(),
        'meaning': _meaningCtrl.text.trim(),
        'example': _exampleCtrl.text.trim(),
        'topic_id': widget.topicId,
      };

      if (widget.wordData == null) {
        await ApiClient().dio.post('/admin/vocabulary', data: payload);
      } else {
        await ApiClient().dio.put(
          '/admin/vocabulary/${widget.wordData['id']}',
          data: payload,
        );
      }
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu thất bại hoặc từ đã tồn tại.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            widget.wordData == null
                                ? 'Thêm từ vựng'
                                : 'Sửa từ vựng',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _wordCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Từ tiếng Anh (*)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _meaningCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nghĩa tiếng Việt (*)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _exampleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Câu ví dụ',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Lưu từ vựng',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
