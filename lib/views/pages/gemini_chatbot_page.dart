import 'package:flutter/material.dart';
import '../../controllers/chatbot_controller.dart';

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({super.key});
  @override
  State<GeminiChatPage> createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  final ChatbotController _ctrl = ChatbotController();
  final TextEditingController _inputCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [];

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _inputCtrl.clear();
    });

<<<<<<< HEAD:lib/pages/chatbot_page.dart
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _messages.add({'role': 'gemini', 'text': 'You need to log in first.'});
      });
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final userData = userDoc.data();

    final selectedCuisine =
        userData?['preferred_cuisine'] ?? 'Pizza, Burger, Wrap';

    final geminiService = GeminiTalkService();
    final response = await geminiService.getResponse(
      prompt,
      selectedCuisine: selectedCuisine,
    );

=======
    final reply = await _ctrl.getResponse(text);
>>>>>>> e8c9f4ad8d4a1426e98f13a725b471eef9b3abc4:lib/views/pages/gemini_chatbot_page.dart
    setState(() {
      _messages.add({'role': 'gemini', 'text': reply});
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
              itemBuilder: (_, i) {
                final msg = _messages[i];
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
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    decoration: const InputDecoration(
                      hintText: "Ask Gemini...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
