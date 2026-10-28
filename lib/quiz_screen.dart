import 'dart:math';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'flashcard.dart';

class QuizScreen extends StatefulWidget {
  final List<Flashcard> cards;

  const QuizScreen({Key? key, required this.cards}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

// "SingleTickerProviderStateMixin" is needed to run the flip animation
class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  int _currentIndex = 0; // which card we are on
  bool _showingAnswer = false; // is the answer side visible?

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  // Flip the card to the other side
  void _flipCard() {
    if (_showingAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showingAnswer = !_showingAnswer;
    });
  }

  // Go to another card. The new card always starts on the question side.
  void _goToCard(int newIndex) {
    _flipController.value = 0;
    setState(() {
      _currentIndex = newIndex;
      _showingAnswer = false;
    });
  }

  // One side of the card (question side or answer side)
  Widget _buildCardFace({
    required String label,
    required String text,
    required LinearGradient gradient,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 36),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Scroll view makes sure long text never overflows the card
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tap card to flip',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // The flipping card. The animation rotates the card from 0 to 180 degrees.
  Widget _buildFlipCard(Flashcard card) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final angle = _flipController.value * pi;
          // Before 90 degrees we see the front, after that we see the back
          final isFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // gives a 3D look
              ..rotateY(angle),
            child: isFront
                ? _buildCardFace(
                    label: 'QUESTION',
                    text: card.question,
                    gradient: AppColors.questionGradient,
                    icon: Icons.help_outline,
                  )
                // The back is turned 180 degrees so the text is not mirrored
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _buildCardFace(
                      label: 'ANSWER',
                      text: card.answer,
                      gradient: AppColors.answerGradient,
                      icon: Icons.lightbulb_outline,
                    ),
                  ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.cards.length;
    final currentCard = widget.cards[_currentIndex];
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == total - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        elevation: 0,
        title: const Text('Quiz Time'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress text and bar
            Text(
              'Card ${_currentIndex + 1} of $total',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / total,
                minHeight: 10,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
            ),
            const SizedBox(height: 24),

            // The card takes all the free space in the middle
            Expanded(child: _buildFlipCard(currentCard)),
            const SizedBox(height: 24),

            // Show Answer button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _flipCard,
                icon: Icon(
                    _showingAnswer ? Icons.visibility_off : Icons.visibility),
                label: Text(_showingAnswer ? 'Hide Answer' : 'Show Answer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Previous and Next buttons (disabled on the first / last card)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        isFirst ? null : () => _goToCard(_currentIndex - 1),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        isLast ? null : () => _goToCard(_currentIndex + 1),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
