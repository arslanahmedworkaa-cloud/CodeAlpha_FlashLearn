import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'flashcard.dart';

class CardStorage {
  static const String _key = 'saved_flashcards';

  // Cards shown the very first time the app is opened
  static List<Flashcard> _sampleCards() {
    return [
      Flashcard(
        id: '1',
        question: 'What is Flutter?',
        answer: 'A toolkit by Google to build mobile apps from one codebase.',
      ),
      Flashcard(
        id: '2',
        question: 'Which language does Flutter use?',
        answer: 'Dart',
      ),
      Flashcard(
        id: '3',
        question: 'What is a Widget?',
        answer: 'The basic building block of every Flutter screen.',
      ),
    ];
  }

  // Load cards from the phone
  static Future<List<Flashcard>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedText = prefs.getString(_key);

      // Nothing saved yet = first time opening the app
      if (savedText == null) {
        return _sampleCards();
      }

      // Convert the saved text back into a list of cards
      final List<dynamic> list = jsonDecode(savedText);
      return list
          .map((item) => Flashcard.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      // If anything goes wrong, show the sample cards instead of crashing
      return _sampleCards();
    }
  }

  // Save cards to the phone
  static Future<void> save(List<Flashcard> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final text = jsonEncode(cards.map((card) => card.toMap()).toList());
      await prefs.setString(_key, text);
    } catch (e) {
      // Saving failed, but the app keeps working
    }
  }
}
