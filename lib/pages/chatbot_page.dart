import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": userMessage});
      _controller.clear();
    });

    final botReply = await getChatbotAnswer(userMessage);

    setState(() {
      _messages.add({"role": "bot", "text": botReply});
    });
  }

  Future<String> getChatbotAnswer(String userMessage) async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('faq_chatbot').get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final keywords = List<String>.from(data['keywords'] ?? []);
      print("🔥 Loaded keywords: $keywords from ${data['question']}");

      for (var keyword in keywords) {
        final keywordPattern = RegExp(
          '\\b${RegExp.escape(keyword)}\\b',
          caseSensitive: false,
        );
        if (keywordPattern.hasMatch(userMessage)) {
          return data['answer'];
        }
      }
    }

    return "Sorry, I couldn't find an answer. Please try rephrasing.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Ask me anything..."),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
