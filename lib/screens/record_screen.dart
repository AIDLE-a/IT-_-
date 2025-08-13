import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/diary_service.dart';
import 'result_screen.dart'; 
import '../models/diary_data.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final TextEditingController _controller = TextEditingController();
  String? selectedEmotion;
  Color selectedColor = Colors.indigo; // 기본 색상
  bool? prefersSimilarMusic;
  String? selectedAgeGroup;
  String? selectedMusicGenre;

  final List<String> ageGroups = ['10대', '20대', '30대', '40대 이상'];
  final List<String> musicGenres = ['밴드', 'K-pop', '인디', '발라드', '국내 팝', 'J-pop', '기타'];
  final List<String> emotionList = [
    '동기부여', '기쁨', '편안', '우울', '실망', '화남'
  ];

  final DiaryService diaryService = DiaryService();
  final uuid = const Uuid();

  // 색상 팔레트(컬러 피커) 표시 함수
  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('색상을 선택하세요'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘의 마음 수정 만들기',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '오늘 하루를 한 줄로 작성',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '비슷한 감정의 노래를 듣는 편인가요?',
                style: TextStyle(fontSize: 14),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('예'),
                      value: true,
                      groupValue: prefersSimilarMusic,
                      onChanged: (value) => setState(() => prefersSimilarMusic = value),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('아니오'),
                      value: false,
                      groupValue: prefersSimilarMusic,
                      onChanged: (value) => setState(() => prefersSimilarMusic = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('연령대를 선택해주세요', style: TextStyle(fontSize: 14)),
              DropdownButton<String>(
                value: selectedAgeGroup,
                hint: const Text('연령대 선택'),
                isExpanded: true,
                items: ageGroups
                    .map((age) => DropdownMenuItem(
                          value: age,
                          child: Text(age),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedAgeGroup = value),
              ),
              const SizedBox(height: 16),
              const Text('좋아하는 음악 장르를 선택해주세요', style: TextStyle(fontSize: 14)),
              DropdownButton<String>(
                value: selectedMusicGenre,
                hint: const Text('음악 장르 선택'),
                isExpanded: true,
                items: musicGenres
                    .map((genre) => DropdownMenuItem(
                          value: genre,
                          child: Text(genre),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedMusicGenre = value),
              ),
              const SizedBox(height: 16),
              const Text('감정을 선택해주세요', style: TextStyle(fontSize: 14)),
              // 감정 선택 버튼 (동기부여, 기쁨, 편안, 우울, 실망, 화남)
              Wrap(
                spacing: 8,
                children: emotionList.map((emotion) {
                  return ChoiceChip(
                    label: Text(emotion),
                    selected: selectedEmotion == emotion,
                    onSelected: (selected) {
                      setState(() {
                        selectedEmotion = selected ? emotion : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('색상을 선택해주세요', style: TextStyle(fontSize: 14)),
              ListTile(
                title: const Text('색상 선택'),
                trailing: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                ),
                onTap: () => _showColorPicker(context),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('오늘 하루를 입력해주세요!')),
                      );
                      return;
                    }
                    if (selectedEmotion == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('감정을 선택해주세요!')),
                      );
                      return;
                    }
                    if (prefersSimilarMusic == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('노래 선호도를 선택해주세요!')),
                      );
                      return;
                    }
                    if (selectedAgeGroup == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('연령대를 선택해주세요!')),
                      );
                      return;
                    }
                    if (selectedMusicGenre == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('음악 장르를 선택해주세요!')),
                      );
                      return;
                    }
                    // 색상이 선택되지 않았다면 기본 색상(Colors.indigo) 사용
                    // (사실 색상은 항상 선택되어 있음)
                    // Color를 Hex 문자열로 변환
                    final colorHex = selectedColor.value.toRadixString(16).substring(2).toUpperCase();
                    
                    final prefs = await SharedPreferences.getInstance();
                    final userName = prefs.getString('userName');
                    if (userName == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인 정보가 없습니다.')),
                      );
                      return;
                    }
                    // 결과 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(
                          mood: selectedEmotion!,
                          message: _controller.text,
                          prefersSimilarMusic: prefersSimilarMusic!,
                          ageGroup: selectedAgeGroup!,
                          musicPreference: selectedMusicGenre!,
                          userName: userName,
                          colorHex: colorHex,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBFA5FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}