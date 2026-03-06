import 'dart:math';

class LocalAIService {
  static Future<String> getResponse(String message) async {
    await Future.delayed(Duration(seconds: 1)); // fake thinking delay

    message = message.toLowerCase();

    if (message.contains("unsafe") || message.contains("scared")) {
      return "I'm really sorry you're feeling unsafe. Try moving to a well-lit area and consider contacting someone you trust. Would you like me to suggest safer nearby zones?";
    }

    if (message.contains("night")) {
      return "If you're walking at night, stay in populated and well-lit streets. Share your live location with a trusted contact if possible.";
    }

    if (message.contains("alone")) {
      return "You're not alone. If possible, call a friend or family member. Staying connected can help you feel safer.";
    }

    if (message.contains("help")) {
      return "If you're in immediate danger, please contact local emergency services. If not urgent, tell me more about your situation so I can guide you.";
    }

    // default intelligent sounding responses
    List<String> defaultReplies = [
      "Thank you for sharing that. Can you tell me more about what’s happening?",
      "I’m here with you. What specifically is making you uncomfortable?",
      "Your safety matters. Let’s think through this calmly together.",
      "That sounds concerning. Are you in a public or isolated area?"
    ];

    return defaultReplies[Random().nextInt(defaultReplies.length)];
  }
}