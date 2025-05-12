import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'gemini_talk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({super.key});

  @override
  State<GeminiChatPage> createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': prompt});
      _controller.clear();
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _messages.add({'role': 'gemini', 'text': 'You need to log in first.'});
      });
      return;
    }

    // 🔹 Step 1: Fetch user data from Firestore
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final userData = userDoc.data();

    final selectedCuisine =
        userData?['preferred_cuisine'] ?? 'Pizza, Burger, Wrap';

    // 🔹 Step 2: Pass to Gemini
    final geminiService = GeminiTalkService();
    final response = await geminiService.getResponse(
      prompt,
      selectedCuisine: selectedCuisine,
    );

    setState(() {
      _messages.add({'role': 'gemini', 'text': response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask Gemini...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
