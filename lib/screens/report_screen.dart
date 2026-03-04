import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/report_tile.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  Widget _locationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on_outlined, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                "Current Location",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "MG Road, Near Central Metro Station",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Change Location",
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GradientHeader(
              title: "Report Safety Concerns",
              subtitle: "Help build a safer community",
            ),
            const SizedBox(height: 18),
            _locationCard(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "What would you like to report?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
                children: [
                  ReportTile(
                    icon: Icons.lightbulb_outline,
                    iconColor: Colors.orange,
                    label: "Poor Lighting",
                    onTap: () {},
                  ),
                  ReportTile(
                    icon: Icons.report_gmailerrorred,
                    iconColor: Colors.red,
                    label: "Harassment",
                    onTap: () {},
                  ),
                  ReportTile(
                    icon: Icons.place_outlined,
                    iconColor: Colors.deepOrange,
                    label: "Isolated Area",
                    onTap: () {},
                  ),
                  ReportTile(
                    icon: Icons.people_outline,
                    iconColor: Colors.blue,
                    label: "Crowded/Safe",
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}