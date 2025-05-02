import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ChatBotService {
  final String _apiKey =
      'AIzaSyCPF2PNeWTlL9AAylFxm3Tox2VfP-lZgZ0'; // Gemini API Key

  Future<String> getBotReply(String message) async {
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyCPF2PNeWTlL9AAylFxm3Tox2VfP-lZgZ0';

    // 🔥 Step 1: Fetch latest offer from Firestore
    String offerText = await _getBestOffer();

    // 🧠 Step 2: Build AI prompt
    final prompt = """
You are a smart and friendly assistant for a restaurant app called "Fancy Feast".
Only respond about:
- cuisines (like Burger, Kacchi, Pizza)
- restaurant names (like KFC, Pizza Hut, etc.)
- restaurant offers and combos
Don't talk about unrelated topics like games or general browsing.

Latest Offer: $offerText

User: $message
""";

    // 🚀 Step 3: Call Gemini API
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final text = decoded["candidates"][0]["content"]["parts"][0]["text"];
      return text;
    } else {
      return "Error: ${response.statusCode} - ${response.body}";
    }
  }

  Future<String> _getBestOffer() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('res001')
              .doc('offers')
              .get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        return data['bestOffer'] ?? "No current offers available.";
      } else {
        return "No offers found.";
      }
    } catch (e) {
      return "Error retrieving offers.";
    }
  }
}
