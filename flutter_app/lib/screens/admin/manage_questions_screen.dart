import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      questions = await service.getQuestions(part: selectedPart);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Câu hỏi'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateQuestionScreen()),
              );
              await loadQuestions();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int?>(
              value: selectedPart,
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
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text('Part ${q['part']} - ${q['content']}'),
                              subtitle: Text(
                                'A. ${q['option_a']}\n'
                                'B. ${q['option_b']}\n'
                                'Đáp án: ${q['correct_answer']}',
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                onPressed: () => deleteQuestion(q['id']),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
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