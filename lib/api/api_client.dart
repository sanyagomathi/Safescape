import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient { 
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');


  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/health")).timeout(
            const Duration(seconds: 5),
          );
      return response.statusCode == 200;
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }
    /// Get AI home insights for an area
    static Future<Map<String, dynamic>?> getHomeInsights({
      required double lat,
      required double lng,
      double radiusKm = 1.5,
      int? hour,
    }) async {
      try {
        final response = await http
            .post(
              Uri.parse("$baseUrl/ai/home-insights"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "lat": lat,
                "lng": lng,
                "radius_km": radiusKm,
                "hour": hour,
              }),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        return null;
      } catch (e) {
        print('Error fetching home insights: $e');
        return null;
      }
    }
  /// Get nearby safe points (police, medical, transit, commercial)
  static Future<List<dynamic>> getNearbySafePoints({
    required double lat,
    required double lng,
    double radiusKm = 2.0,
    String? category,
    int limit = 200,
  }) async {
    try {
      String url =
          "$baseUrl/safe-points/nearby?lat=$lat&lng=$lng&radius_km=$radiusKm&limit=$limit";
      if (category != null) url += "&category=$category";

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching safe points: $e');
      return [];
    }
  }

  /// Get nearby street segments
  static Future<List<dynamic>> getNearbySegments({
    required double lat,
    required double lng,
    double radiusKm = 1.0,
    int limit = 200,
  }) async {
    try {
      final url =
          "$baseUrl/segments/nearby?lat=$lat&lng=$lng&radius_km=$radiusKm&limit=$limit";
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching segments: $e');
      return [];
    }
  }

  /// Get safety score for a segment at specific hour
  static Future<Map<String, dynamic>?> getSegmentScore(
    String segmentId,
    int hour,
  ) async {
    try {
      if (hour < 0 || hour > 23) return null;

      final url = "$baseUrl/scores/$segmentId/$hour";
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching score: $e');
      return null;
    }
  }

  /// Submit a review for a segment
  static Future<bool> submitReview({
    required String segmentId,
    required String category,
    required String gender,
    required int hour,
    required double rating,
    String note = "",
  }) async {
    try {
      final body = jsonEncode({
        "segment_id": segmentId,
        "category": category,
        "gender": gender,
        "hour": hour,
        "rating": rating,
        "note": note,
      });

      final response = await http
          .post(
            Uri.parse("$baseUrl/reviews"),
            headers: {"Content-Type": "application/json"},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }
}