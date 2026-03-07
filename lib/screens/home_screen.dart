import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),

      appBar: AppBar(
        title: const Text("SafeEscape"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// SAFE AREA STATUS
            const Text(
              "Safe Area Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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