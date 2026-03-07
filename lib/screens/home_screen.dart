import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../widgets/gradient_header.dart';
import '../widgets/ai_assistant.dart';
import '../api/api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool backendConnected = false;
  int segmentsCount = 0;
  int safePointsCount = 0;
  String testStatus = "";
  String currentLocation = "Detecting location...";
    bool insightsLoading = false;
  String insightsSummary = "";
  List<String> insightHighlights = [];

 @override
  void initState() {
    super.initState();
    getLocation();
    _runApiTest();
    _loadHomeInsights();
  }
  Future<void> _loadHomeInsights() async {
      setState(() {
        insightsLoading = true;
      });

      const double lat = 28.6139;
      const double lng = 77.2090;

      final data = await ApiClient.getHomeInsights(
        lat: lat,
        lng: lng,
        radiusKm: 1.5,
        hour: DateTime.now().hour,
      );

      setState(() {
        insightsLoading = false;

        if (data != null) {
          insightsSummary = (data["summary"] ?? "").toString();
          insightHighlights = ((data["highlights"] ?? []) as List)
              .map((e) => e.toString())
              .toList();
        } else {
          insightsSummary = "Could not load AI insights right now.";
          insightHighlights = [];
        }
      });
    }
  Future<void> _runApiTest() async {
  setState(() {
    testStatus = "Testing API...";
  });

  // Same demo coords you use in your map (New Delhi)
  const double lat = 28.6139;
  const double lng = 77.2090;

  final segs = await ApiClient.getNearbySegments(
    lat: lat,
    lng: lng,
    radiusKm: 2.0,
    limit: 50,
  );

  final points = await ApiClient.getNearbySafePoints(
    lat: lat,
    lng: lng,
    radiusKm: 2.0,
    limit: 50,
  );

  setState(() {
    segmentsCount = segs.length;
    safePointsCount = points.length;
  });

  if (segs.isNotEmpty) {
    print("First segment JSON: ${segs.first}");
  } else {
    print("No segments returned (seed segments first).");
  }

  if (points.isNotEmpty) {
    print("First safe point JSON: ${points.first}");
  } else {
    print("No safe points returned (insert/seed safe_points).");
  }
}
    Future<void> getLocation() async {
      try {
        setState(() {
          currentLocation = "Checking location services...";
        });

        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            currentLocation = "Turn on Location Services";
          });
          return;
        }

        setState(() {
          currentLocation = "Checking permission...";
        });

        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied) {
          setState(() {
            currentLocation = "Location permission denied";
          });
          return;
        }

        if (permission == LocationPermission.deniedForever) {
          setState(() {
            currentLocation = "Location permission denied forever";
          });
          return;
        }

        setState(() {
          currentLocation = "Getting coordinates...";
        });

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );

        setState(() {
          currentLocation = "Finding place name...";
        });

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isEmpty) {
          setState(() {
            currentLocation =
                "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
          });
          return;
        }

        final place = placemarks.first;
        final locality = place.locality?.trim();
        final area = place.subLocality?.trim();
        final state = place.administrativeArea?.trim();

        setState(() {
          currentLocation = [
            if (area != null && area.isNotEmpty) area,
            if (locality != null && locality.isNotEmpty) locality,
            if (state != null && state.isNotEmpty) state,
          ].join(", ");
        });
      } catch (e) {
        setState(() {
          currentLocation = "Location error: $e";
        });
        debugPrint("Location error: $e");
      }
    }
    Widget _aiInsightsCard() {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlueDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Scout AI Insights",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Smart summary of your nearby area",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: insightsLoading ? null : _loadHomeInsights,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (insightsLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Text(
                insightsSummary.isEmpty
                    ? "No AI insights available yet."
                    : insightsSummary,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              if (insightHighlights.isNotEmpty) ...[
                const SizedBox(height: 14),
                ...insightHighlights.take(4).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      );
    }
    Widget _locationBanner() {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlueDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Location",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentLocation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  Widget infoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(title),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  floatingActionButton: FloatingActionButton.extended(
  backgroundColor: AppTheme.primaryBlue,
  label: const Text("Chat with Scout"),
  icon: const Icon(Icons.smart_toy),

  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: AIAssistant(),
        ),
      ),
    );
  },
),
  body: SingleChildScrollView(
        child: Column(
          children: [
            const GradientHeader(
              title: "SAFESCAPE",
              subtitle: "Emotional Safety Intelligence",
            ),
            _locationBanner(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),

            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: infoCard(
                      title: "Safe Areas",
                      value: safePointsCount.toString(),
                      subtitle: "confirmed safe points",
                      icon: Icons.trending_up,
                      iconColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: infoCard(
                      title: "Alerts",
                      value: "3",
                      subtitle: "nearby cautions.                  . ",
                      icon: Icons.warning,
                      iconColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            _aiInsightsCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}