class ChatbotQA {
  final String question;
  final String answer;
  final List<String> keywords;

  ChatbotQA({
    required this.question,
    required this.answer,
    required this.keywords,
  });

  factory ChatbotQA.fromFirestore(Map<String, dynamic> data) {
    return ChatbotQA(
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      keywords: List<String>.from(data['keywords'] ?? []),
    );
  }
}

class SmallTalk {
  final List<String> triggers;
  final List<String> responses;

  SmallTalk({required this.triggers, required this.responses});

  factory SmallTalk.fromFirestore(Map<String, dynamic> data) {
    return SmallTalk(
      triggers: List<String>.from(data['triggers'] ?? []),
      responses: List<String>.from(data['responses'] ?? []),
    );
  }
}
