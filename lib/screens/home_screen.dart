import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  @override


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
    testStatus = "OK ✅ Segments=$segmentsCount | SafePoints=$safePointsCount";
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

  Widget roundedMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(28.6139, 77.2090), // New Delhi demo
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.safescape',
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
  floatingActionButton: FloatingActionButton(
    backgroundColor: Colors.deepPurple,
    child: const Icon(Icons.smart_toy),
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
            const SizedBox(height: 10),
          
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                testStatus,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 12),
            roundedMap(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: infoCard(
                      title: "Safe Areas",
                      value: safePointsCount.toString(),
                      subtitle: "from backend",
                      icon: Icons.trending_up,
                      iconColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: infoCard(
                      title: "Alerts",
                      value: "3",
                      subtitle: "nearby cautions",
                      icon: Icons.warning,
                      iconColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}