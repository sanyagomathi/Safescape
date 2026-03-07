import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:url_launcher/url_launcher.dart';
=======
import 'package:flutter_application_1/theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
>>>>>>> 77950dbc68b5e6df30508993e5765e53217d32f1

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

<<<<<<< HEAD
  void callNumber(String number) async {
    final Uri url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget sosButton(String title, IconData icon, Color color, String number) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => callNumber(number),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
              )
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
=======
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool backendConnected = false;
  int segmentsCount = 0;
  int safePointsCount = 0;
  String testStatus = "";
  String currentLocation = "Detecting location...";

 @override
  void initState() {
    super.initState();
    getLocation();
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
>>>>>>> 77950dbc68b5e6df30508993e5765e53217d32f1
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xfff4f6f8),

      appBar: AppBar(
        title: const Text("SafeEscape"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
=======
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
>>>>>>> 77950dbc68b5e6df30508993e5765e53217d32f1
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD

            /// SAFE AREA STATUS
            const Text(
              "Safe Area Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
=======
            const GradientHeader(
              title: "SAFESCAPE",
              subtitle: "Emotional Safety Intelligence",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text(
                    currentLocation,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                testStatus,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
>>>>>>> 77950dbc68b5e6df30508993e5765e53217d32f1
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff11998e),
                    Color(0xff38ef7d)
                  ],
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Colors.white, size: 35),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "You are currently in a Safe Zone",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ALERTS
            const Text(
              "Nearby Alerts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                  )
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Suspicious activity reported 1 km away",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            /// SOS CONTACTS
            const Text(
              "Emergency SOS",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sosButton(
                  "Police",
                  Icons.local_police,
                  Colors.blue,
                  "100",
                ),
                sosButton(
                  "Ambulance",
                  Icons.medical_services,
                  Colors.red,
                  "102",
                ),
                sosButton(
                  "Hospital",
                  Icons.local_hospital,
                  Colors.green,
                  "108",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}