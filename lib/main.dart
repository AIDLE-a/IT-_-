import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;

import 'firebase_options.dart';

// 화면 import
import 'screens/record_screen.dart';
import 'screens/emotion_chart.dart';
import 'screens/history_page.dart';
import 'screens/moon_crystal_screen.dart';
import 'screens/about_page.dart';
import 'models/diary_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  GoogleSignInPlatform.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartCrystalApp',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.hasData ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 본인 웹용 OAuth 클라이언트 ID
  final String clientId =
      '518473307904-k8l8nd6o12kejbsjpro6k1ldi5vev6g6.apps.googleusercontent.com';

  GoogleSignIn? _googleSignIn;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      clientId: clientId,
      scopes: ['email', 'profile'],
    );

    if (kIsWeb) {
      // 앱 시작 시 + 주기적으로 로그인 상태 체크
      _continuousSilentSignIn();
    }
  }

  Future<void> _firebaseSignIn(GoogleSignInAccount account) async {
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', account.displayName ?? '');
    await prefs.setString('userEmail', account.email);
  }

  /// 로그인 상태를 계속 감시 → 계정 생기면 즉시 Firebase 연동
  void _continuousSilentSignIn() async {
    // 최초 시도
    _trySilentOnce();
    // 0.5초 간격으로 계속 체크 (1~2초 내 전환 확정)
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      final account = await _googleSignIn!.signInSilently();
      if (account != null) {
        await _firebaseSignIn(account);
        return false; // 로그인되면 반복 종료
      }
      return FirebaseAuth.instance.currentUser == null;
    });
  }

  Future<void> _trySilentOnce() async {
    final account = await _googleSignIn!.signInSilently();
    if (account != null) {
      await _firebaseSignIn(account);
    }
  }

  Future<void> _mobileSignIn() async {
    final account = await _googleSignIn!.signIn();
    if (account != null) {
      await _firebaseSignIn(account);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: kIsWeb
            ? (GoogleSignInPlatform.instance as web.GoogleSignInPlugin)
                .renderButton(
                configuration: web.GSIButtonConfiguration(
                  theme: web.GSIButtonTheme.outline,
                  size: web.GSIButtonSize.large,
                  text: web.GSIButtonText.signin,
                  shape: web.GSIButtonShape.pill,
                ),
              )
            : ElevatedButton.icon(
                onPressed: _mobileSignIn,
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('Google로 로그인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  ButtonStyle get mainButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBFA5FF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('마음 수정'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => _logout(context), icon: const Icon(Icons.logout)),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙
            crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙
            children: [
              if (user?.photoURL != null)
                CircleAvatar(backgroundImage: NetworkImage(user!.photoURL!), radius: 40),
              const SizedBox(height: 8),
              Text(user?.displayName ?? '사용자'),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const RecordScreen())),
                  style: mainButtonStyle,
                  child: const Text('오늘의 마음 수정 만들기')),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => EmotionChartPage())),
                  style: mainButtonStyle,
                  child: const Text('감정 그래프 보기')),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const HistoryPage())),
                  style: mainButtonStyle,
                  child: const Text('지난 기록 보기')),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const MoonCrystalScreen())),
                  style: mainButtonStyle,
                  child: const Text('이달의 감정 달력')),
            ],
          ),
        ),
      ),
    );
  }
}
