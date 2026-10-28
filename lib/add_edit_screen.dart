import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'flashcard.dart';

class AddEditScreen extends StatefulWidget {
  final Flashcard? card; // null means "add new card"

  const AddEditScreen({Key? key, this.card}) : super(key: key);

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  bool get isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    // When editing, fill the boxes with the old text
    _questionController =
        TextEditingController(text: widget.card?.question ?? '');
    _answerController = TextEditingController(text: widget.card?.answer ?? '');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  // Check the form, create the card and send it back to the Home screen
  void _saveCard() {
    if (!_formKey.currentState!.validate()) {
      return; // stop if a box is empty
    }

    final newCard = Flashcard(
      // Keep the same id when editing, make a new id when adding
      id: widget.card?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
    );

    Navigator.pop(context, newCard);
  }

  // Same look for both text boxes
  InputDecoration _boxStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.purple),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.purple, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        elevation: 0,
        title: Text(isEditing ? 'Edit Card' : 'New Card'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Question (front of the card)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _questionController,
              minLines: 2,
              maxLines: 4,
              decoration: _boxStyle('Type your question', Icons.help_outline),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Answer (back of the card)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _answerController,
              minLines: 2,
              maxLines: 4,
              decoration: _boxStyle('Type the answer', Icons.lightbulb_outline),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an answer';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveCard,
                icon: const Icon(Icons.check),
                label: Text(isEditing ? 'Save Changes' : 'Add Card'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
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
          ],
        ),
      ),
    );
  }
}
