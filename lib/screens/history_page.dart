import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/diary_service.dart';
import '../models/diary_data.dart';


class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});


  @override
  State<HistoryPage> createState() => _HistoryPageState();
}


class _HistoryPageState extends State<HistoryPage> {
  final DiaryService diaryService = DiaryService();
  Future<List<DiaryEntry>>? _entriesFuture;


  @override
  void initState() {
    super.initState();
    _loadEntries();
  }


  void _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');
    if (userName == null) {
      setState(() {
        _entriesFuture = Future.value([]);
      });
      return;
    }
    setState(() {
      _entriesFuture = diaryService.getEntries(userName).catchError((e) {
        // 에러 발생 시 빈 리스트 반환
        return [];
      });
    });
  }


  Future<void> _deleteEntry(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');
    if (userName == null) return;


    await diaryService.deleteEntry(userName, entryId);
    setState(() {
      _entriesFuture = diaryService.getEntries(userName); // 삭제 후 리스트 갱신
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_entriesFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text("지난 감정 일기")),
      body: FutureBuilder<List<DiaryEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('저장된 감정 기록이 없습니다.'));
          }
          final entries = snapshot.data!;
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              // colorHex가 없을 경우 기본 색상(회색) 사용
              final color = e.color ?? Colors.grey;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.emotion,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('MM/dd').format(e.date), // 날짜 포맷
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(e.content, style: const TextStyle(fontSize: 16)),
                      if (e.musicGenre != null && e.musicGenre!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '장르: ${e.musicGenre}',
                          style: const TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                      if (e.comfortMessage != null && e.comfortMessage!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '위로메시지: ${e.comfortMessage}',
                          style: const TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // 자신이 선택한 감정 색상 표시
                      Row(
                        children: [
                          const Text('감정 색상: ', style: TextStyle(fontSize: 14)),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 삭제 버튼
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('삭제 확인'),
                                content: const Text('이 기록을 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('삭제'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _deleteEntry(e.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('기록이 삭제되었습니다.')),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
