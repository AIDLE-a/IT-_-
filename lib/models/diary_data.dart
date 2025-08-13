import 'package:flutter/material.dart';

class DiaryEntry {
  final String id;
  final DateTime date;
  final String content;
  final String emotion;
  final String? musicGenre;
  final String? comfortMessage;
  final String? colorHex; // 추가: 색상 정보

  DiaryEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.emotion,
    this.musicGenre,
    this.comfortMessage,
    this.colorHex, // 추가
  });

    factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      content: json['content'] ?? '',
      emotion: json['emotion'] ?? '',
      musicGenre: json['musicGenre'] ?? '',
      comfortMessage: json['comfortMessage'],
      colorHex: json['colorHex'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'emotion': emotion,
      'musicGenre': musicGenre,
      'comfortMessage': comfortMessage,
      'colorHex': colorHex, // 추가
    };
  }
  

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      content: map['content'],
      emotion: map['emotion'],
      musicGenre: map['musicGenre'],
      comfortMessage: map['comfortMessage'],
      colorHex: map['colorHex'], // 추가
    );
  }

  // colorHex를 Color로 변환하는 getter (try-catch 추가)
  Color? get color {
    if (colorHex == null) return null;
    try {
      return Color(int.parse('0xFF$colorHex'));
    } catch (e) {
      return null;
    }
  }

  // 여러 DiaryEntry의 색상을 평균 혼합하는 static 메서드
  static Color mixColors(List<DiaryEntry> entries) {
    if (entries.isEmpty) return Colors.transparent;
    int r = 0, g = 0, b = 0, a = 0;
    int validCount = 0;
    for (var entry in entries) {
      if (entry.colorHex == null) continue;
      final color = entry.color;
      if (color == null) continue; // 추가 null 체크(선택)
      r += color.red;
      g += color.green;
      b += color.blue;
      a += color.alpha;
      validCount++;
    }
    if (validCount == 0) return Colors.transparent;
    r = (r / validCount).round();
    g = (g / validCount).round();
    b = (b / validCount).round();
    a = (a / validCount).round();
    return Color.fromARGB(a, r, g, b);
  }
}