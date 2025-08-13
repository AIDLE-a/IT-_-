import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/diary_service.dart';
import '../models/diary_data.dart';
import 'package:uuid/uuid.dart';

// 감정별 색상 팔레트 예시 (필요에 따라 조정)
final Map<String, Color> moodColors = {
  '우울': const Color(0xFF868686),
  '기쁨': const Color(0xFFFFDE59),
  '화남': const Color(0xFFFF6B6B),
  '동기부여': const Color(0xFF4B69C6),
  '실망': const Color(0xFFB0A8B9),
  '편안': const Color.fromARGB(255, 11, 167, 229),
};

class ResultScreen extends StatefulWidget {
  final String mood;
  final String message;
  final bool prefersSimilarMusic;
  final String ageGroup;
  final String musicPreference;
  final String userName;
  final String colorHex;

  const ResultScreen({
    super.key,
    required this.mood,
    required this.message,
    required this.prefersSimilarMusic,
    required this.ageGroup,
    required this.musicPreference,
    required this.userName,
    required this.colorHex,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ChatService chatService = ChatService('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');
  final DiaryService diaryService = DiaryService();
  final uuid = const Uuid();
  String? gptResponse;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGPTResponse();
  }

  Future<void> fetchGPTResponse() async {
    try {
      final response = await chatService.getComfortMessage(
        mood: widget.mood,
        userMessage: widget.message,
        ageGroup: widget.ageGroup,
        musicPreference: widget.musicPreference,
        prefersSimilarMusic: widget.prefersSimilarMusic,
      );
      setState(() {
        gptResponse = response;
        isLoading = false;
      });

      // GPT 위로 메시지와 함께 기록 저장
      final diaryEntry = DiaryEntry(
        id: uuid.v4(),
        date: DateTime.now(),
        content: widget.message,
        emotion: widget.mood,
        musicGenre: widget.musicPreference,
        comfortMessage: gptResponse,
        colorHex: widget.colorHex,
      );
      await diaryService.saveEntry(widget.userName, diaryEntry);
    } catch (e) {
      setState(() {
        gptResponse = '위로 메시지를 불러오는 데 실패했습니다.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Color(int.parse('0xFF${widget.colorHex}'));
    final textColor = selectedColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: selectedColor,
        title: Text(
          '오늘의 마음 수정',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isLoading
            ? Center( // ← 가로·세로 중앙 배치
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 내용 크기에 딱 맞게
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      '위로 메시지를 불러오는 중...',
                      style: TextStyle(color: selectedColor),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '당신의 마음: ${widget.message}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Text('연령대: ${widget.ageGroup}'),
                    Text('좋아하는 음악 장르: ${widget.musicPreference}'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          '감정 색상:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: selectedColor, // 선택 색상
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '오늘의 위로 메시지:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        gptResponse ?? '',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor,
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('뒤로 가기'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
