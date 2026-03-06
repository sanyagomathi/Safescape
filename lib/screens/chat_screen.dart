import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Chat"),
      ),
      body: Column(
  children: [

    /// Chat messages area
    Expanded(
      child: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index]),
          );
        },
      ),
    ),

    /// Input area
    Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [

          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type your message...",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendMessage,
          )

        ],
      ),
    )

  ],
)