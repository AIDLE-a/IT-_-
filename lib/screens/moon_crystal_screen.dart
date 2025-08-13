import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bgColor = Color(0xFFF4EBFF);

/// 월별 날짜수 계산
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

class MoonCrystalScreen extends StatefulWidget {
  const MoonCrystalScreen({Key? key}) : super(key: key);

  @override
  State<MoonCrystalScreen> createState() => _MoonCrystalScreenState();
}

class _MoonCrystalScreenState extends State<MoonCrystalScreen> {
  late DateTime selectedMonth; // 현재 보고 있는 월
  Map<int, String> dayToColorHex = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
    _loadEmotionData();
  }

  Future<void> _loadEmotionData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');
    if (userName == null) {
      setState(() {
        dayToColorHex = {};
        isLoading = false;
      });
      return;
    }

    final rawEntries = prefs.getStringList('diary_entries_$userName') ?? [];
    Map<int, String> tempMap = {};
    for (var rawEntry in rawEntries) {
      try {
        final map = jsonDecode(rawEntry);
        final date = DateTime.parse(map['date']);
        // 선택된 달/년도 기록만 불러옴
        if (date.year == selectedMonth.year && date.month == selectedMonth.month) {
          final hex = map['colorHex'];
          if (hex != null && hex.toString().isNotEmpty) {
            tempMap[date.day] = hex.toString().toUpperCase();
          }
        }
      } catch (_) {}
    }

    setState(() {
      dayToColorHex = tempMap;
      isLoading = false;
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + offset, 1);
    });
    _loadEmotionData();
  }

  void _showColorInfoDialog(int day) {
    final hex = dayToColorHex[day];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${selectedMonth.year}-${selectedMonth.month}월 ${day}일 감정색'),
        content: hex != null
            ? Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF$hex')),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('HEX: #$hex'),
                ],
              )
            : const Text('감정색 정보가 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Color getEmotionColor(int day) {
    final hex = dayToColorHex[day];
    if (hex == null) return Colors.grey[300]!;
    try {
      return Color(int.parse('0xFF$hex'));
    } catch (_) {
      return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = daysInMonth(selectedMonth.year, selectedMonth.month);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('${selectedMonth.year}년 ${selectedMonth.month}월 감정 달력'),
        centerTitle: true,
        backgroundColor: bgColor,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
          IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: totalDays,
                itemBuilder: (context, idx) {
                  final day = idx + 1;
                  final color = getEmotionColor(day);
                  return GestureDetector(
                    onTap: () => _showColorInfoDialog(day),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black12)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$day', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.favorite, color: color, size: 28),
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
