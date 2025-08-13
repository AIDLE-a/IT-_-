import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/diary_data.dart';

class EmotionChart extends StatelessWidget {
  final List<DiaryEntry> entries;
  final DateTime selectedMonth;

  const EmotionChart({
    required this.entries,
    required this.selectedMonth,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredEntries = entries.where((e) =>
        e.date.year == selectedMonth.year &&
        e.date.month == selectedMonth.month).toList();

    final Map<String, DiaryEntry> dailyMap = {};
    for (var entry in filteredEntries) {
      final key = DateFormat('yyyy-MM-dd').format(entry.date);
      dailyMap[key] = entry;
    }

    final sortedKeys = dailyMap.keys.toList()..sort();
    final List<FlSpot> spots = [];
    final Map<int, String> xLabels = {};

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final entry = dailyMap[key]!;
      final score = _emotionToScore(entry.emotion);
      if (score != null) {
        spots.add(FlSpot(i.toDouble(), score.toDouble()));
        xLabels[i] = DateFormat('MM/dd').format(entry.date);
      }
    }

    // 감정별 라벨
    final List<String> emotionLabels = [
      '화남',
      '실망',
      '우울',
      '편안',
      '기쁨',
      '동기부여',
    ];

    // 그래프 높이와 라벨 위치 계산
    final double graphHeight = 500;
    final double labelHeight = graphHeight / (emotionLabels.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('yyyy년 M월').format(selectedMonth)} 감정 흐름'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            height: graphHeight,
            width: double.infinity,
            child: Stack(
              children: [
                // 그래프
                Positioned(
                  left: 60, // Y축 라벨 공간 확보
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: LineChart(
                    LineChartData(
                      minY: 1,
                      maxY: 6,
                      baselineY: 1,
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
                          sideTitles: SideTitles(
                            showTitles: false, // 직접 그릴 예정
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final label = xLabels[value.toInt()];
                              return label != null
                                  ? Text(label, style: TextStyle(fontSize: 12))
                                  : Container();
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
                // Y축 라벨 직접 그리기
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int i = emotionLabels.length - 1; i >= 0; i--)
                        Container(
                          height: labelHeight,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            emotionLabels[i],
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int? _emotionToScore(String emotion) {
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
        return null;
    }
  }
}