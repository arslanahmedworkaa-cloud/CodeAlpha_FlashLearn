class Flashcard {
  final String id; // unique number so we can tell cards apart
  final String question;
  final String answer;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
  });

  // Turns a card into a Map so it can be saved as text (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

  // Builds a card back from a saved Map
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'].toString(),
      question: map['question'].toString(),
      answer: map['answer'].toString(),
    );
  }
}
