import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoonCrystalScreen extends StatefulWidget {
  const MoonCrystalScreen({Key? key}) : super(key: key);

  @override
  State<MoonCrystalScreen> createState() => _MoonCrystalScreenState();
}

class _MoonCrystalScreenState extends State<MoonCrystalScreen> {
  static const int maxPieces = 31;
  static const Color bgColor = Color(0xFFF4EBFF); // 연보라 배경색
  static const double heartWidth = 300;
  static const double heartHeight = 340;

  Map<int, String> dayToColorHex = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiaryColors();
  }

  Future<void> _loadDiaryColors() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');
    final now = DateTime.now();

    if (userName == null) {
      setState(() => isLoading = false);
      return;
    }

    final rawEntries = prefs.getStringList('diary_entries_$userName') ?? [];
    Map<int, String> tempMap = {};
    for (var rawEntry in rawEntries) {
      try {
        final map = jsonDecode(rawEntry);
        final date = DateTime.parse(map['date']);
        if (date.year == now.year && date.month == now.month) {
          final colorHex = map['colorHex'];
          if (colorHex != null && colorHex.toString().isNotEmpty) {
            tempMap[date.day] = colorHex.toString().toUpperCase();
          }
        }
      } catch (_) {}
    }

    setState(() {
      dayToColorHex = tempMap;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text('달에 새긴 마음수정 조각'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: bgColor,
              child: Center(
                child: SizedBox(
                  width: heartWidth,
                  height: heartHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(
                      maxPieces,
                      (index) {
                        final day = index + 1;
                        final assetPath = 'assets/heart_piece_$day.PNG';

                        final hex = dayToColorHex[day];
                        Color color;
                        if (hex == null) {
                          color = bgColor; // 감정색 없으면 배경색으로
                        } else {
                          try {
                            color = Color(int.parse('0xFF$hex'));
                          } catch (_) {
                            color = bgColor;
                          }
                        }

                        return ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            color.withOpacity(0.75),
                            BlendMode.srcATop,
                          ),
                          child: Image.asset(
                            assetPath,
                            width: heartWidth,
                            height: heartHeight,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: heartWidth,
                              height: heartHeight,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.red, size: 42),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
