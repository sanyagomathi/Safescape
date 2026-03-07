
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../widgets/gradient_header.dart';
import '../theme.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  String selectedMode = "Walk";
  bool isSearching = false;
  

  void swapLocations() {
  final temp = fromController.text;
  fromController.text = toController.text;
  toController.text = temp;
  setState(() {});
}
void updateSuggestions(String value, bool isFrom) {
  final q = value.trim().toLowerCase();

  final matches = recentPlaces
      .where((p) => p.toLowerCase().contains(q))
      .toList();

  setState(() {
    if (isFrom) {
      fromSuggestions = q.isEmpty ? [] : matches;
    } else {
      toSuggestions = q.isEmpty ? [] : matches;
    }
  });
}
  final List<String> recentPlaces = [
    "Bandra Station, Mumbai",
    "Juhu Beach, Mumbai",
    "Dadar Station, Mumbai",
    "Gateway of India, Mumbai",
    "Andheri West, Mumbai",
  ];

  List<String> fromSuggestions = [];
  List<String> toSuggestions = [];

  final MapController mapController = MapController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  List<Polyline> routeLines = [];

  LatLng? startPoint;
  LatLng? endPoint;

  @override
  void initState() {
  super.initState();
  }
  

  Future<List<LatLng>> getRoadRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
 final profile = selectedMode == "Drive"
    ? "driving"
    : selectedMode == "Bike"
        ? "bike"
        : "foot";

      final url =
          "https://router.project-osrm.org/route/v1/$profile/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson";
          
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body);
    final coords = data["routes"][0]["geometry"]["coordinates"] as List;

    return coords
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
  }

  Future<void> generateSafeColoredRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    final routePoints = await getRoadRoute(startLat, startLng, endLat, endLng);

    if (routePoints.isEmpty) {
      print("No route returned");
      return;
    }

    List<Polyline> lines = [];

    // 1. Base full route in green
    lines.add(
      Polyline(
        points: routePoints,
        strokeWidth: 8,
        color: Colors.green,
      ),
    );

    // 2. Overlay only caution/riskier sections
    for (int i = 0; i < routePoints.length - 1; i += 8) {
      final p1 = routePoints[i];
      final p2 = routePoints[i + 1];

      final segments = await ApiClient.getNearbySegments(
        lat: p1.latitude,
        lng: p1.longitude,
        radiusKm: 0.2,
        limit: 3,
      );

      double safety = 0.8; // assume safe unless backend says otherwise

      if (segments.isNotEmpty) {
        final id = segments.first["id"];

        final score = await ApiClient.getSegmentScore(
          id.toString(),
          DateTime.now().hour,
        );

        safety = (score?["overall"] as num?)?.toDouble() ?? 0.8;
      }

      // 3. Only draw overlays for caution or risk
      if (safety <= 0.7 && safety > 0.4) {
        lines.add(
          Polyline(
            points: [p1, p2],
            strokeWidth: 10,
            color: Colors.orange,
          ),
        );
      } else if (safety <= 0.4) {
        lines.add(
          Polyline(
            points: [p1, p2],
            strokeWidth: 10,
            color: Colors.red,
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      routeLines = lines;
    });

    final bounds = LatLngBounds.fromPoints(routePoints);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(30),
        ),
      );
    });
  }

  Future<LatLng?> geocodePlace(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "User-Agent": "com.example.safescape",
      },
    );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as List;
      if (data.isEmpty) return null;

      final lat = double.parse(data[0]["lat"]);
      final lon = double.parse(data[0]["lon"]);

      return LatLng(lat, lon);
  }


Widget _locationField({
  required TextEditingController controller,
  required IconData icon,
  required String hint,
  required bool isFrom,
}) {
  final suggestions = isFrom ? fromSuggestions : toSuggestions;

  return Column(
    children: [
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (value) => updateSuggestions(value, isFrom),
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      if (suggestions.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: suggestions.map((place) {
              return ListTile(
                dense: true,
                leading: const Icon(Icons.history, size: 18),
                title: Text(place),
                onTap: () {
                  controller.text = place;
                  setState(() {
                    if (isFrom) {
                      fromSuggestions = [];
                    } else {
                      toSuggestions = [];
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
    ],
  );
}
Widget _modeButton({
  required String label,
  required IconData icon,
}) {
  final isActive = selectedMode == label;

  return Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = label;
        });
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue : AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryBlue
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _modeDropdown() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedMode,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: "Walk", child: Text("Walk")),
          DropdownMenuItem(value: "Drive", child: Text("Drive")),
          DropdownMenuItem(value: "Bike", child: Text("Bike")),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            selectedMode = value;
          });
        },
      ),
    ),
  );
}
@override
void dispose() {
  fromController.dispose();
  toController.dispose();
  super.dispose();
}
 
 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppTheme.lightGrey,
    body: Stack(
      children: [
        Positioned.fill(
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
              PolylineLayer(
                polylines: routeLines,
              ),
              MarkerLayer(
                markers: [
                  if (startPoint != null)
                    Marker(
                      point: startPoint!,
                      width: 50,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.trip_origin,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Start",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (endPoint != null)
                    Marker(
                      point: endPoint!,
                      width: 50,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "End",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            ),
        ),

        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: GradientHeader(
            title: "Safe Navigation",
            subtitle: "Find the safest route to your destination",
          ),
        ),

         if (routeLines.isNotEmpty)
          Positioned(
            top: 120,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 12,
                  ),
                ],
              ),
              ),
          ),


        DraggableScrollableSheet(
          initialChildSize: 0.28,
          minChildSize: 0.14,
          maxChildSize: 0.65,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _locationField(
                                    controller: fromController,
                                    icon: Icons.location_on_outlined,
                                    hint: "Your location",
                                    isFrom: true,
                                  ),
                                  const SizedBox(height: 10),
                                  _locationField(
                                    controller: toController,
                                    icon: Icons.send_outlined,
                                    hint: "Where to?",
                                    isFrom: false,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: GestureDetector(
                                onTap: swapLocations,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightGrey,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.black.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: const Icon(Icons.swap_vert),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _modeButton(
                            label: "Walk",
                            icon: Icons.directions_walk,
                          ),
                          const SizedBox(width: 8),
                          _modeButton(
                            label: "Car",
                            icon: Icons.directions_car,
                          ),
                          const SizedBox(width: 8),
                          _modeButton(
                            label: "Cycle",
                            icon: Icons.directions_bike,
                          ),
                        ],
                      ),
        const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final fromText = fromController.text.trim();
                            final toText = toController.text.trim();

                            if (fromText.isEmpty || toText.isEmpty) return;

                            final fromLatLng = await geocodePlace(fromText);
                            final toLatLng = await geocodePlace(toText);

                            if (fromLatLng == null || toLatLng == null) {
                              print("Location not found");
                              return;
                            }

                            setState(() {
                                startPoint = fromLatLng;
                                endPoint = toLatLng;
                              });

                            await generateSafeColoredRoute(
                              fromLatLng.latitude,
                              fromLatLng.longitude,
                              toLatLng.latitude,
                              toLatLng.longitude,
                            );
                          },
                          child: const Text(
                            "Find Safe Route",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
