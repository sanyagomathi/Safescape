import 'package:flutter/material.dart';

class ChangeLocationScreen extends StatefulWidget {
  final String currentLocation;

  const ChangeLocationScreen({super.key, required this.currentLocation});

  @override
  State<ChangeLocationScreen> createState() => _ChangeLocationScreenState();
}

class _ChangeLocationScreenState extends State<ChangeLocationScreen> {

  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.currentLocation);
  }

  void saveLocation() {
    Navigator.pop(context, controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Location")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Enter new location",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveLocation,
              child: const Text("Save Location"),
            )

          ],
        ),
      ),
    );
  }
}