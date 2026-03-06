import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AIAssistant extends StatefulWidget {
  const AIAssistant({super.key});

  @override
  State<AIAssistant> createState() => _AIAssistantState();
}

class _AIAssistantState extends State<AIAssistant> {

  final TextEditingController controller = TextEditingController();

  String response = "";
  bool loading = false;

  void askAI() async {

    if (controller.text.isEmpty) return;

    setState(() {
      loading = true;
      response = "";
    });

    final reply = await AIService.askAI(controller.text);

    setState(() {
      response = reply;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                "AI Safety Assistant",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Ask AI about safety...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: askAI,
            child: const Text("Ask AI"),
          ),

          const SizedBox(height: 10),

          if (loading)
            const CircularProgressIndicator(),

          if (response.isNotEmpty)
            Text(response),
        ],
      ),
    );
  }
}