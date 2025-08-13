import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 정보'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: const [
            Text(
              '마음 수정 (Heart Crystal)',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '🌟 감성을 기록하고 치유하는 나만의 성장 공간',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),
            Text(
              '📌 마음수정의 핵심 가치',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              '감정은 빛나는 조각으로 남는다.\n'
              '수정은 어둠 속에서 더욱 빛나듯,\n'
              '감정도 기록될 때 빛을 발한다.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              '🛠️ 주요 기능',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              '- 감정 일기 작성\n'
              '- 감정 흐름 그래프 시각화\n'
              '- 일별 감정 상세 보기\n'
              '- AI 위로 메시지 & 추천 음악 제공\n'
              '- 이달의 감정 달력',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              '👩‍💻 개발자',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              '성신여자대학교 AI융합학부\n주희선, 김연우, 이유빈, 김채민',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
