import 'package:flutter/material.dart';

class AgentAIScreen extends StatelessWidget {
  const AgentAIScreen({Key? key}) : super(key: key);

  Widget featureCard(String title, String description, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agentic AI Assistant"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Meet Your Safety AI Agent",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "An intelligent assistant designed to provide emotional support, safety guidance, and proactive suggestions.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Features
            featureCard(
              "Emotional Awareness",
              "Understands fear, anxiety, and unsafe situations.",
              Icons.psychology,
            ),

            featureCard(
              "Proactive Safety Suggestions",
              "Suggests safer areas, trusted contacts, and next steps.",
              Icons.security,
            ),

            featureCard(
              "Real-Time Risk Analysis (Prototype)",
              "Simulates safety scoring for your surroundings.",
              Icons.analytics,
            ),

            featureCard(
              "Conversational Support",
              "Provides calm and supportive responses.",
              Icons.chat,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
              child: const Text(
                "Try AI Demo",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}