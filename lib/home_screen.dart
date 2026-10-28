import 'package:flutter/material.dart';
import 'add_edit_screen.dart';
import 'app_colors.dart';
import 'card_storage.dart';
import 'flashcard.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Flashcard> _cards = [];
  bool _isLoading = true; // true while cards are being loaded

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  // Get the saved cards when the screen opens
  Future<void> _loadCards() async {
    final loadedCards = await CardStorage.load();
    setState(() {
      _cards = loadedCards;
      _isLoading = false;
    });
  }

  // ADD: open the form, and wait for the new card to come back
  Future<void> _addCard() async {
    final newCard = await Navigator.push<Flashcard>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditScreen()),
    );

    if (newCard != null) {
      setState(() {
        _cards.add(newCard);
      });
      CardStorage.save(_cards);
    }
  }

  // EDIT: open the form with the old card, and replace it with the new one
  Future<void> _editCard(int index) async {
    final updatedCard = await Navigator.push<Flashcard>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditScreen(card: _cards[index]),
      ),
    );

    if (updatedCard != null) {
      setState(() {
        _cards[index] = updatedCard;
      });
      CardStorage.save(_cards);
    }
  }

  // DELETE: ask first, so a card is not deleted by mistake
  Future<void> _deleteCard(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete this card?'),
        content: const Text('You cannot undo this.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _cards.removeAt(index);
      });
      CardStorage.save(_cards);
    }
  }

  void _openQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(cards: _cards)),
    );
  }

  // Purple top part with the title and the Start Quiz button
  Widget _buildHeader() {
    final topSpace = MediaQuery.of(context).padding.top + 16;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topSpace, 24, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.questionGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_stories, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'FlashLearn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _cards.length == 1
                ? '1 card ready to study'
                : '${_cards.length} cards ready to study',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            // Button is disabled when there are no cards
            onPressed: _cards.isEmpty ? null : _openQuiz,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Message shown when there are no cards
  Widget _buildEmptyMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.style, size: 80, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'No flashcards yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap "Add Card" to make your first one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  // One row in the list
  Widget _buildCardTile(int index) {
    final card = _cards[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Number badge
          CircleAvatar(
            backgroundColor: AppColors.purple.withOpacity(0.12),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Question and answer preview
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.answer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit, color: AppColors.teal),
            onPressed: () => _editCard(index),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteCard(index),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      // Extra space at the bottom so the + button does not cover the last card
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      itemCount: _cards.length,
      itemBuilder: (context, index) => _buildCardTile(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_cards.isEmpty) {
      content = _buildEmptyMessage();
    } else {
      content = _buildList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCard,
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: content),
        ],
      ),
    );
  }
}
