import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme.dart';
import '../services/ai_service.dart';

class AIAssistant extends StatefulWidget {
  const AIAssistant({super.key});

  @override
  State<AIAssistant> createState() => _AIAssistantState();
}

class _AIAssistantState extends State<AIAssistant> {
  final TextEditingController controller = TextEditingController();
  final List<ChatMessage> messages = [];
  bool loading = false;

  static const double demoLat = 28.6139;
  static const double demoLng = 77.2090;

  Future<void> askAI() async {
    final text = controller.text.trim();
    if (text.isEmpty || loading) return;

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
      loading = true;
    });

    controller.clear();

    try {
      final history = messages
    .map((m) => {
          'role': m.isUser ? 'user' : 'assistant',
          'text': m.text,
        })
    .toList();

final reply = await AIService.askAI(
  message: text,
  lat: demoLat,
  lng: demoLng,
  history: history,
  hour: DateTime.now().hour,
);

      setState(() {
        messages.add(ChatMessage(text: reply, isUser: false));
      });
    } catch (e) {
      setState(() {
        messages.add(
          ChatMessage(
            text: "Sorry, I could not get a response right now.",
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _chatBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy, color: AppTheme.primaryBlue),
              SizedBox(width: 8),
              Text(
                "AI Safety Assistant",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      "Ask me about safety, nearby help, or safe movement advice.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _chatBubble(messages[index]);
                    },
                  ),
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(),
            ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => askAI(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: askAI,
                icon: const Icon(Icons.send),
                color: AppTheme.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}