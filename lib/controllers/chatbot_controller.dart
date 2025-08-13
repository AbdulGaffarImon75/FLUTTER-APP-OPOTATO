// lib/controllers/chatbot_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatbotController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final Gemini _gemini = Gemini.instance;

  /// Return the user's preferred cuisine, or null if none set.
  Future<String?> _fetchPreferredCuisine() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _fs.collection('users').doc(user.uid).get();
    return (doc.data()?['preferred_cuisine'] as String?);
  }

  /// Load every cuisine label from Firestore.
  Future<List<String>> _fetchAllCuisines() async {
    final snap = await _fs.collection('cuisines').get();
    return snap.docs
        .map((d) => d.data()['label'].toString())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Load every combo document.
  Future<List<Map<String, dynamic>>> _fetchAllCombos() async {
    final snap = await _fs.collection('combos').get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Load every offer document.
  Future<List<Map<String, dynamic>>> _fetchAllOffers() async {
    final snap = await _fs.collection('offers').get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Main entry-point: applies the same logic to both combos and offers.
  Future<String> getResponse(String userInput) async {
    // 1) Auth guard
    final user = _auth.currentUser;
    if (user == null) {
      return 'You need to log in first.';
    }

    // 2) Fetch all dynamic data
    final selectedCuisine = await _fetchPreferredCuisine();
    final allCuisines = await _fetchAllCuisines();
    final combos = await _fetchAllCombos();
    final offers = await _fetchAllOffers();

    // 3) Detect a mentioned combo or offer
    Map<String, dynamic>? matchedCombo;
    for (var c in combos) {
      final title = (c['title'] ?? '').toString().toLowerCase();
      if (userInput.toLowerCase().contains(title)) {
        matchedCombo = c;
        break;
      }
    }

    Map<String, dynamic>? matchedOffer;
    if (matchedCombo == null) {
      for (var o in offers) {
        final name = (o['name'] ?? '').toString().toLowerCase();
        if (userInput.toLowerCase().contains(name)) {
          matchedOffer = o;
          break;
        }
      }
    }

    // 4) Build the “detail” section
    String detailSection;
    if (matchedCombo != null) {
      detailSection = '''
The user asked about our combo "${matchedCombo['title']}"  
• Price: ${matchedCombo['price']}  
• Vendor: ${matchedCombo['vendor']}  

Please give a brief, engaging description of this combo and encourage them to explore it.
''';
    } else if (matchedOffer != null) {
      detailSection = '''
The user asked about our offer "${matchedOffer['name']}"  
• Price: ${matchedOffer['price']}  
• Vendor: ${matchedOffer['posted_by']}  

Please describe this offer in an enticing way and encourage them to grab it.
''';
    } else {
      // Gather just the names for fallback suggestions:
      final cuisineList = allCuisines.join(', ');
      final offerNames = offers
          .map((o) => o['name'].toString())
          .where((s) => s.isNotEmpty)
          .join(', ');

      detailSection = '''
No known combo or offer was mentioned.  
Please suggest alternative food items or combos using our cuisines: $cuisineList.  
Also feel free to highlight some of our current offers: $offerNames.  
You can also point them to our "menu" collection.
''';
    }

    // 5) Assemble the final prompt
    final prompt = '''
You are OPotato AI — a friendly food-discovery chatbot. Keep your responses concise and engaging.

$detailSection
User preferences:
- Cuisine: ${selectedCuisine ?? 'Any'}

User message: "$userInput"
''';

    // 6) Send to Gemini
    try {
      final result = await _gemini.text(prompt);
      return result?.output ?? 'Sorry, I couldn’t find a good match.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
