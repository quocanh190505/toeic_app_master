import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_client.dart';

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
      final response = await _dio.get('/vocabulary/topics');
      setState(() {
        topics = response.data;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
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
            _TopicImage(imageUrl: topic['image_url']?.toString()),
            const SizedBox(height: 12),
            Text(
              topic['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                topic['description'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicImage extends StatelessWidget {
  final String? imageUrl;

  const _TopicImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Icon(Icons.style, size: 50, color: AppTheme.primary);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        ApiConstants.uploadUrl(imageUrl),
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.style, size: 50, color: AppTheme.primary);
        },
      ),
    );
  }
}

class WordListScreen extends StatefulWidget {
  final int topicId;
  final String topicName;

  const WordListScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final Dio _dio = ApiClient().dio;
  final PageController _pageController = PageController(viewportFraction: 0.92);

  List<dynamic> words = [];
  bool loading = true;
  int currentIndex = 0;
  final Set<int> flippedIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    _fetchWords();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        currentIndex = 0;
        flippedIndexes.clear();
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _toggleStudied(int wordId, int index) async {
    final isStudied = words[index]['is_studied'] ?? false;

    try {
      if (isStudied) {
        await _dio.delete('/vocabulary/$wordId/study');
      } else {
        await _dio.post('/vocabulary/$wordId/study');
      }

      setState(() {
        words[index]['is_studied'] = !isStudied;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isStudied
                ? 'Đã bỏ đánh dấu đã học cho từ này'
                : 'Đã đánh dấu từ này là đã học',
          ),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật: $e')),
      );
    }
  }

  void _toggleFlip(int index) {
    setState(() {
      if (flippedIndexes.contains(index)) {
        flippedIndexes.remove(index);
      } else {
        flippedIndexes.add(index);
      }
    });
  }

  void _goToCard(int newIndex) {
    if (newIndex < 0 || newIndex >= words.length) return;
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicName)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : words.isEmpty
              ? _buildEmptyState()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: words.length,
                            onPageChanged: (index) {
                              setState(() => currentIndex = index);
                            },
                            itemBuilder: (context, index) {
                              final word = words[index];
                              final isFlipped = flippedIndexes.contains(index);
                              final isStudied = word['is_studied'] ?? false;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: _Flashcard(
                                  word: word,
                                  isFlipped: isFlipped,
                                  isStudied: isStudied,
                                  onFlip: () => _toggleFlip(index),
                                  onMarkStudied: () =>
                                      _toggleStudied(word['id'], index),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildControls(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final studiedCount =
        words.where((word) => (word['is_studied'] ?? false) == true).length;
    final progress = words.isEmpty ? 0.0 : (currentIndex + 1) / words.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9F1FF), Color(0xFFF7FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentIndex + 1}/${words.length} thẻ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$studiedCount từ đã đánh dấu thuộc',
                      style: const TextStyle(color: AppTheme.subText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final canGoBack = currentIndex > 0;
    final canGoNext = currentIndex < words.length - 1;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: canGoBack ? () => _goToCard(currentIndex - 1) : null,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Thẻ trước'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canGoNext ? () => _goToCard(currentIndex + 1) : null,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(canGoNext ? 'Thẻ tiếp theo' : 'Hoàn thành'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.style_outlined, size: 56, color: AppTheme.subText),
            const SizedBox(height: 12),
            const Text(
              'Chưa có từ vựng cho chủ đề này',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy kiểm tra lại dữ liệu seed hoặc thêm từ mới từ màn quản trị.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.subText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWords,
              child: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Flashcard extends StatelessWidget {
  final dynamic word;
  final bool isFlipped;
  final bool isStudied;
  final VoidCallback onFlip;
  final VoidCallback? onMarkStudied;

  const _Flashcard({
    required this.word,
    required this.isFlipped,
    required this.isStudied,
    required this.onFlip,
    required this.onMarkStudied,
  });

  @override
  Widget build(BuildContext context) {
    final example = (word['example'] ?? '').toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onFlip,
        child: Ink(
          decoration: BoxDecoration(
            gradient: isFlipped
                ? const LinearGradient(
                    colors: [Color(0xFF0F62FE), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Colors.white, Color(0xFFF8FAFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x160F172A),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isFlipped
                            ? Colors.white.withValues(alpha: 0.18)
                            : const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isFlipped ? 'Mặt sau' : 'Mặt trước',
                        style: TextStyle(
                          color: isFlipped ? Colors.white : AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isStudied
                          ? Icons.check_circle_rounded
                          : Icons.touch_app_rounded,
                      color: isStudied
                          ? (isFlipped ? Colors.white : AppTheme.success)
                          : (isFlipped ? Colors.white70 : AppTheme.subText),
                    ),
                  ],
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: isFlipped
                      ? _CardBack(
                          key: const ValueKey('back'),
                          meaning: word['meaning']?.toString() ?? '',
                          example: example,
                        )
                      : _CardFront(
                          key: const ValueKey('front'),
                          word: word['word']?.toString() ?? '',
                        ),
                ),
                const Spacer(),
                Text(
                  isFlipped
                      ? 'Chạm để quay lại từ tiếng Anh'
                      : 'Chạm để xem nghĩa tiếng Việt',
                  style: TextStyle(
                    color: isFlipped ? Colors.white70 : AppTheme.subText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onMarkStudied,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isStudied
                          ? (isFlipped ? Colors.white : AppTheme.success)
                          : (isFlipped ? Colors.white : AppTheme.primary),
                      foregroundColor: isStudied
                          ? (isFlipped ? AppTheme.success : Colors.white)
                          : (isFlipped ? AppTheme.primary : Colors.white),
                    ),
                    icon: Icon(
                      isStudied ? Icons.check_rounded : Icons.school_rounded,
                    ),
                    label: Text(
                      isStudied ? 'Bỏ đánh dấu đã học' : 'Đánh dấu đã học',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final String word;

  const _CardFront({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.translate_rounded,
              size: 44, color: AppTheme.primary),
          const SizedBox(height: 20),
          Text(
            word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Nhìn từ tiếng Anh trước rồi đoán nghĩa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.subText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final String meaning;
  final String example;

  const _CardBack({
    super.key,
    required this.meaning,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Nghĩa tiếng Việt',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          meaning,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        if (example.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ví dụ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  example,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
