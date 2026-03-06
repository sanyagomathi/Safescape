import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme.dart';
import '../widgets/gradient_header.dart';

class NavigateScreen extends StatelessWidget {
  const NavigateScreen({super.key});

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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: const GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(19.0760, 72.8777),
                    zoom: 14,
                  ),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}