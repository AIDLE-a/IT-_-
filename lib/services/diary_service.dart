import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_data.dart';

class DiaryService {
  // userName을 키에 포함하여 각 사용자별로 저장

  Future<void> saveEntry(String userName, DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'diary_entries_$userName';
    final List<String> entries = prefs.getStringList(key) ?? [];

    entries.add(jsonEncode(entry.toMap()));
    await prefs.setStringList(key, entries);
  }

  Future<List<DiaryEntry>> getEntries(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'diary_entries_$userName';
    final List<String> entries = prefs.getStringList(key) ?? [];

    return entries.map((e) => DiaryEntry.fromMap(jsonDecode(e))).toList();
  }

  // 감정 기록 삭제 함수 추가
  Future<void> deleteEntry(String userName, String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'diary_entries_$userName';
    List<String> entries = prefs.getStringList(key) ?? [];

    // entryId와 일치하는 항목만 남기고 삭제
    entries.removeWhere((entry) {
      final map = jsonDecode(entry);
      return map['id'] == entryId;
    });

    await prefs.setStringList(key, entries);
  }
}