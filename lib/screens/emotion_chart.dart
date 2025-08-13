import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/diary_service.dart';
import '../models/diary_data.dart';

class EmotionChartPage extends StatefulWidget {
  @override
  _EmotionChartPageState createState() => _EmotionChartPageState();
}

class _EmotionChartPageState extends State<EmotionChartPage> {
  final DiaryService diaryService = DiaryService();
  List<DiaryEntry> entries = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
    if (userName == null) {
      return;
    }
    diaryService.getEntries(userName!).then((data) {
      setState(() {
        entries = data;
      });
    });
  }

  int _emotionToScore(String emotion) {
    switch (emotion.trim()) {
      case '화남':
        return 1;
      case '실망':
        return 2;
      case '우울':
        return 3;
      case '편안':
        return 4;
      case '기쁨':
        return 5;
      case '동기부여':
        return 6;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userName == null) {
      return Scaffold(
        appBar: AppBar(title: Text('감정 그래프')),
        body: Center(child: Text('로그인 정보가 없습니다.')),
      );
    }
    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('감정 그래프')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 날짜별로 정렬
    entries.sort((a, b) => a.date.compareTo(b.date));
    List<FlSpot> spots = [];
    Map<int, String> xLabels = {};
    for (int i = 0; i < entries.length; i++) {
      final score = _emotionToScore(entries[i].emotion);
      if (score != 0) {
        spots.add(FlSpot(i.toDouble(), score.toDouble()));
        xLabels[i] = '${entries[i].date.month}/${entries[i].date.day}';
      }
    }

    final List<String> emotionLabels = [
      '화남', '실망', '우울', '편안', '기쁨', '동기부여'
    ];
    final double graphHeight = MediaQuery.of(context).size.height * 0.6;

    return Scaffold(
      appBar: AppBar(title: Text('감정 흐름 곡선')),
      body: Center(
        child: SizedBox(
          height: graphHeight,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 60,
                right: 0,
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 30.0), // 오른쪽 여백 추가
                  child: LineChart(
                    LineChartData(
                      minY: 1,
                      maxY: 6,
                      minX: 0,
                      maxX: xLabels.length > 0 ? (xLabels.length - 1).toDouble() : 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 4,
                          color: Colors.indigo,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.indigo.withOpacity(0.3),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 50, // 충분히 크게
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              final label = xLabels[idx];
                              if (label == null) return Container();
                              // 마지막 라벨만 오른쪽 정렬
                              if (idx == xLabels.length - 1) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(label, style: TextStyle(fontSize: 12)),
                                );
                              }
                              // 첫 번째 라벨만 왼쪽 정렬
                              if (idx == 0) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(label, style: TextStyle(fontSize: 12)),
                                );
                              }
                              // 나머지는 가운데
                              return Align(
                                alignment: Alignment.center,
                                child: Text(label, style: TextStyle(fontSize: 12)),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
              // Y축 라벨
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = emotionLabels.length - 1; i >= 0; i--)
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            emotionLabels[i],
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
