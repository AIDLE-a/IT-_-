import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String apiKey;

  ChatService(this.apiKey);

  Future<String> getComfortMessage({
    required String mood,
    required String userMessage,
    required String ageGroup,
    required String musicPreference,
    required bool prefersSimilarMusic,
  }) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final similarity = prefersSimilarMusic ? "비슷한 감정의" : "상반된 감정의";

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content":
                  "당신은 감정을 위로하고 음악을 추천하는 따뜻한 챗봇입니다. 사용자의 감정, 하루 요약, 연령대, 음악 취향 정보를 바탕으로 공감과 위로의 문장을 작성하고, 사용자가 듣고 싶어할 만한 $similarity 음악 장르에서 한 곡을 추천해주세요."
            },
            {
              "role": "user",
              "content":
                  "내 감정은 '$mood'이고, 오늘의 마음은 '$userMessage'입니다. 나는 '$ageGroup'이며, '$musicPreference' 장르를 좋아합니다. $similarity 노래를 듣고 싶어요. 위로와 노래 추천을 해주세요."
            }
          ],
          "max_tokens": 500,
          "temperature": 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        print('응답 실패 코드: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        throw Exception('Failed to fetch GPT response');
      }
    } catch (e) {
      print('HTTP 요청 중 예외 발생: $e');
      rethrow;
    }
  }
}
