import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {

  static const String apiKey = "YOUR_GEMINI_API_KEY";

  static Future<String> askAI(String message) async {

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey"
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    final data = jsonDecode(response.body);

    if (data["candidates"] != null) {
      return data["candidates"][0]["content"]["parts"][0]["text"];
    }

    return "AI could not generate a response.";
  }
}