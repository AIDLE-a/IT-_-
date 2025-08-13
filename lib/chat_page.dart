import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/chat_service.dart';
import 'screens/history_page.dart';
import 'screens/emotion_chart.dart';
import 'screens/moon_crystal_screen.dart'; // 감정 색 달력 화면

// 🟢 1. ChatPage (AI 위로 챗봇)
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final chatService = ChatService('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'); // 본인 API 키

  String _reply = '';
  bool _isLoading = false;

  Future<void> _sendToGPT() async {
    final mood = _moodController.text.trim();
    final message = _messageController.text.trim();
    if (mood.isEmpty || message.isEmpty) return;

    setState(() {
      _isLoading = true;
      _reply = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final ageGroup = prefs.getString('ageGroup') ?? '20대';
      final musicPreference = prefs.getString('musicPreference') ?? 'K-pop';
      final prefersSimilarMusic = prefs.getBool('prefersSimilarMusic') ?? true;

      final reply = await chatService.getComfortMessage(
        mood: mood,
        userMessage: message,
        ageGroup: ageGroup,
        musicPreference: musicPreference,
        prefersSimilarMusic: prefersSimilarMusic,
      );

      setState(() {
        _reply = reply;
      });
    } catch (e) {
      setState(() {
        _reply = '오류 발생: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('감성 위로 챗봇')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _moodController,
              decoration: const InputDecoration(
                labelText: '현재 감정을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: '오늘 하루를 한 줄로 표현해 주세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _sendToGPT,
              child: const Text('GPT에게 위로 받기'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(_reply, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// 🟢 2. MainMenuPage (메인 메뉴)
class MainMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("마음수정"),
        actions: [
          if (user?.photoURL != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user != null) ...[
                Text(
                  '안녕하세요, ${user.displayName ?? '사용자'}님!',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
              ],

              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage()));
                },
                child: const Text("감성 위로 챗봇"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage()));
                },
                child: const Text("지난 기록 보기"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EmotionChartPage()));
                },
                child: const Text("감정 그래프 보기"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MoonCrystalScreen()));
                },
                child: const Text("감정 색 달력 보기"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

