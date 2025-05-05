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
