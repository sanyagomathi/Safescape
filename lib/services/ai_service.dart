import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static Future<String> askAI({
    required String message,
    required double lat,
    required double lng,
    required List<Map<String, String>> history,
    double radiusKm = 1.5,
    int? hour,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'lat': lat,
        'lng': lng,
        'radius_km': radiusKm,
        'hour': hour,
        'history': history,
      }),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('AI request failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['reply'] ?? 'No response from AI').toString();
  }
}