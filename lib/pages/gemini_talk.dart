import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiTalkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Gemini _gemini = Gemini.instance;

  Future<String> getResponse(
    String userInput, {
    String? selectedCuisine,
    String? selectedDiet,
    String? selectedIngredient,
  }) async {
    try {
      // 🔹 Step 1: Fetch Combo Titles from Firestore
      final comboSnapshot = await _firestore.collection('combos').get();
      final combos =
          comboSnapshot.docs
              .map((doc) => doc['title'].toString().toLowerCase())
              .toList();

      // 🔹 Step 2: Check if user input matches a known combo
      String? matchedCombo;
      for (final title in combos) {
        if (userInput.toLowerCase().contains(title)) {
          matchedCombo = title;
          break;
        }
      }

      // 🔹 Step 3: Build Gemini Prompt
      final prompt = '''
You are OPotato AI — a helpful chatbot for a food discovery app. Based on our real-time data:

${matchedCombo != null ? "✅ The user asked about an available combo called \"$matchedCombo\". Please provide a brief, engaging description of this combo and encourage them to explore it." : "❌ The user did not match any known combo title. Suggest alternative food items or combos using cuisines: Pizza, Burger, Wrap, Biriyani, Kacchi. You can also suggest Offers or Menus."}

Their preferences:
- Cuisine: ${selectedCuisine ?? 'Any'}

User message: "$userInput"
''';

      final result = await _gemini.text(prompt);
      return result?.output ?? 'Sorry, I couldn’t find a good match.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
