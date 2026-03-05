import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../api/api_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/gradient_header.dart';
import '../theme.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
    List<Polyline> routeLines = [];

    final MapController mapController = MapController();
    bool _fitOnce = false;
    bool loadingRoutes = false;

    @override
    void initState() {
      super.initState();
      loadSafetyRoutes();
    }
    Future<List<LatLng>> getRoadRoute(
          double startLat,
          double startLng,
          double endLat,
          double endLng) async {

        final url =
            "https://router.project-osrm.org/route/v1/foot/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson";

        final response = await http.get(Uri.parse(url));

        if (response.statusCode != 200) {
          return [];
        }

        final data = jsonDecode(response.body);

        final coords =
            data["routes"][0]["geometry"]["coordinates"] as List;

        return coords
            .map((c) => LatLng(c[1], c[0]))
            .toList();
      }

  
      Future<void> loadSafetyRoutes() async {
          if (loadingRoutes) return;
          loadingRoutes = true;
          final lat = 19.0760;
          final lng = 72.8777;

          final segments = await ApiClient.getNearbySegments(
            lat: lat,
            lng: lng,
            radiusKm: 1.5,
            limit: 50,
          );

          print("Segments received: ${segments.length}");

          List<Polyline> lines = [];

          for (var seg in segments) {

            final id = seg["id"];
            final segLat = (seg["lat"] as num).toDouble();
            final segLng = (seg["lng"] as num).toDouble();

            double safety = (DateTime.now().millisecond % 100) / 100;

            Color color;
            if (safety > 0.7) {
              color = Colors.green;
            } else if (safety > 0.4) {
              color = Colors.orange;
            } else {
              color = Colors.red;
            }

            final routePoints =
                await getRoadRoute(segLat, segLng, segLat + 0.002, segLng + 0.002);

            if (routePoints.isNotEmpty) {
              lines.add(
                Polyline(
                  points: routePoints,
                  strokeWidth: 10,
                  color: color,
                ),
              );
            }
          }
        // ✅ print once AFTER loop
          print("Total polylines: ${lines.length}");

          setState(() {
            routeLines = lines;
          });

          // ✅ Fit using `lines`, not `routeLines`
          if (!_fitOnce && lines.isNotEmpty) {
            _fitOnce = true;

            final allPoints = <LatLng>[];
            for (final pl in lines) {
              allPoints.addAll(pl.points);
            }

            if (allPoints.isNotEmpty) {
              final bounds = LatLngBounds.fromPoints(allPoints);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(30),
                  ),
                );
              });
            }
          }

          loadingRoutes = false;  
 }
  
   Widget _inputCard({
    required IconData icon,
    required String hint,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: Column(
        children: [
          const GradientHeader(
            title: "Safe Navigation",
            subtitle: "Find the safest route to your destination",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  children: [
                    _inputCard(icon: Icons.location_on_outlined, hint: "Your location"),
                    const SizedBox(height: 14),
                    _inputCard(icon: Icons.send_outlined, hint: "Where to?"),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Find Safe Routes",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 420,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: FlutterMap(
                         mapController: mapController,
                          options: const MapOptions(
                            initialCenter: LatLng(19.0760, 72.8777),
                            initialZoom: 14,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              userAgentPackageName: "com.example.safescape",
                            ),
                            PolylineLayer(polylines: routeLines),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}