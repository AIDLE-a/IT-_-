import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  final String clientId =
      '518473307904-k8l8nd6o12kejbsjpro6k1ldi5vev6g6.apps.googleusercontent.com';

  /// Firebase 로그인 처리
  Future<void> _signInWithFirebase(
      BuildContext context, GoogleSignInAccount account) async {
    try {
      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 로그인
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 간단히 사용자 정보 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', account.displayName ?? '');
      await prefs.setString('userEmail', account.email);

      // StreamBuilder에서 자동으로 HomeScreen 전환
    } catch (e) {
      debugPrint("구글 로그인 실패: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("구글 로그인 실패: $e")));
      }
    }
  }

  /// 모바일/직접처리 로그인 버튼 공통 사용
  Future<void> _manualSignIn(BuildContext context) async {
    final googleSignIn = GoogleSignIn(
      clientId: clientId,
      scopes: ['email', 'profile'],
    );
    final account = await googleSignIn.signIn();
    if (account != null) {
      await _signInWithFirebase(context, account);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Center(
        child: kIsWeb
            // ✅ 웹: renderButton만 출력
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (GoogleSignInPlatform.instance
                          as web.GoogleSignInPlugin)
                      .renderButton(
                    configuration: web.GSIButtonConfiguration(
                      theme: web.GSIButtonTheme.outline,
                      size: web.GSIButtonSize.large,
                      text: web.GSIButtonText.signin,
                      shape: web.GSIButtonShape.pill,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("위 버튼 클릭 후 Google 로그인 허용하면 자동 전환됩니다."),
                ],
              )
            // ✅ 모바일: 수동 ElevatedButton
            : ElevatedButton.icon(
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('Google로 로그인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _manualSignIn(context),
              ),
      ),
    );
  }
}
