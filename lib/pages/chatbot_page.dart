import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_nav_bar.dart';

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

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    final userProfile = await fetchUserProfile(userId);
    final userName = userProfile?['name'] ?? 'there';

    final botReply = await getChatbotAnswer(userMessage, userName);

    await FirebaseFirestore.instance.collection('chat_history').add({
      'userId': userId,
      'userName': userName,
      'message': userMessage,
      'response': botReply,
      'timestamp': Timestamp.now(),
    });

    setState(() {
      _messages.add({"role": "bot", "text": botReply});
    });
  }

  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<String> getChatbotAnswer(String userMessage, String userName) async {
    final msg = userMessage.toLowerCase();

    // 🔹 0. Check Goodbye Phrases
    final goodbyeSnapshot =
        await FirebaseFirestore.instance.collection('goodbye_chatbot').get();
    for (var doc in goodbyeSnapshot.docs) {
      final data = doc.data();
      final triggers = List<String>.from(data['triggers'] ?? []);
      final responses = List<String>.from(data['responses'] ?? []);

      for (var trigger in triggers) {
        if (msg.similarityTo(trigger.toLowerCase()) > 0.7) {
          return responses.isNotEmpty
              ? "${responses[Random().nextInt(responses.length)]} $userName!"
              : "Bye $userName!";
        }
      }
    }

    // 🔹 1. Check Small Talk
    final smalltalkSnapshot =
        await FirebaseFirestore.instance.collection('smalltalk_chatbot').get();
    for (var doc in smalltalkSnapshot.docs) {
      final data = doc.data();
      final triggers = List<String>.from(data['triggers'] ?? []);
      final responses = List<String>.from(data['responses'] ?? []);

      for (var trigger in triggers) {
        if (msg.similarityTo(trigger.toLowerCase()) > 0.6) {
          return responses.isNotEmpty
              ? "${responses[Random().nextInt(responses.length)]} $userName!"
              : "Hi $userName!";
        }
      }
    }

    // 🔹 2. Check FAQ
    final faqSnapshot =
        await FirebaseFirestore.instance.collection('faq_chatbot').get();
    for (var doc in faqSnapshot.docs) {
      final data = doc.data();
      final keywords = List<String>.from(data['keywords'] ?? []);

      for (var keyword in keywords) {
        if (msg.similarityTo(keyword.toLowerCase()) > 0.6) {
          return data['answer'] ?? "";
        }
      }
    }

    return "Sorry, I didn't understand that. You can ask about booking, food, or our location!";
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
                    decoration: InputDecoration(
                      hintText: " Ask me anything...",
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(activeIndex: 4),
    );
  }
}
