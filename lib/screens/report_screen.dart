import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/report_tile.dart';
import 'change_location_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {

  bool submitting = false;
  String status = "";

  String location = "MG Road, Near Central Metro Station";

  Future<void> submitReport(String type) async {

    setState(() {
      submitting = true;
      status = "Submitting report...";
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      submitting = false;
      status = "$type report submitted successfully";
    });

  }

  Future<void> openChangeLocation() async {

    final newLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeLocationScreen(
          currentLocation: location,
        ),
      ),
    );

    if (newLocation != null) {
      setState(() {
        location = newLocation;
      });
    }
  }

  Widget locationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(Icons.location_on_outlined),
              SizedBox(width: 8),
              Text(
                "Current Location",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(location, style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 16),

          Center(
            child: GestureDetector(
              onTap: openChangeLocation,
              child: Text(
                "Change Location",
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget reportGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),

        mainAxisSpacing: 14,
        crossAxisSpacing: 14,

        children: [

          ReportTile(
            icon: Icons.lightbulb_outline,
            iconColor: Colors.orange,
            label: "Poor Lighting",
            onTap: () => submitReport("Poor Lighting"),
          ),

          ReportTile(
            icon: Icons.report_gmailerrorred,
            iconColor: Colors.red,
            label: "Harassment",
            onTap: () => submitReport("Harassment"),
          ),

          ReportTile(
            icon: Icons.place_outlined,
            iconColor: Colors.deepOrange,
            label: "Isolated Area",
            onTap: () => submitReport("Isolated Area"),
          ),

          ReportTile(
            icon: Icons.people_outline,
            iconColor: Colors.blue,
            label: "Crowded / Safe",
            onTap: () => submitReport("Crowded Area"),
          ),

        ],
      ),
    );
  }

  Widget statusRow() {
    if (status.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        status,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,

      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const GradientHeader(
              title: "Report Safety Concerns",
              subtitle: "Help build a safer community",
            ),

            const SizedBox(height: 18),

            locationCard(),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "What would you like to report?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            reportGrid(),

            const SizedBox(height: 20),

            statusRow(),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}