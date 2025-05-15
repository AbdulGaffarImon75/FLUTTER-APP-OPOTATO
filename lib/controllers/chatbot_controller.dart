import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatbotController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Gemini _gemini = Gemini.instance;

  /// Fetches the user’s preferred cuisine (or default).
  Future<String> _fetchPreferredCuisine() async {
    final user = _auth.currentUser;
    if (user == null) return 'Pizza, Burger, Wrap';
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    return data?['preferred_cuisine'] as String? ?? 'Pizza, Burger, Wrap';
  }

  /// Retrieves all combo titles (lowercased) from Firestore.
  Future<List<String>> _fetchComboTitles() async {
    final snap = await _firestore.collection('combos').get();
    return snap.docs
        .map((d) => (d.data()['title'] ?? '').toString().toLowerCase())
        .toList();
  }

  /// Sends [userInput] to Gemini along with context; returns the AI’s response.
  Future<String> getResponse(String userInput) async {
    final cuisine = await _fetchPreferredCuisine();
    final comboTitles = await _fetchComboTitles();

    // Detect if user asked about a known combo
    String? matchedCombo;
    for (final t in comboTitles) {
      if (userInput.toLowerCase().contains(t)) {
        matchedCombo = t;
        break;
      }
    }

    final prompt = '''
You are OPotato AI — a helpful chatbot for a food discovery app. Based on our real-time data:

${matchedCombo != null ? 'The user asked about combo "$matchedCombo". Please describe it briefly and encourage them to explore it.' : 'No combo matched. Suggest alternative food items or combos using cuisines: Pizza, Burger, Wrap, Biriyani, Kacchi.'}

Their preferences:
- Cuisine: $cuisine

User message: "$userInput"
''';

    try {
      final result = await _gemini.text(prompt);
      return result?.output ?? 'Sorry, I couldn’t find a good match.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
