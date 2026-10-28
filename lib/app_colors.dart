import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF5F3FF);
  static const Color purple = Color(0xFF6C4DF6);
  static const Color darkPurple = Color(0xFF4A2FC4);
  static const Color teal = Color(0xFF14B8A6);
  static const Color darkTeal = Color(0xFF0D8F82);
  static const Color textDark = Color(0xFF2D2A4A);
  static const Color textLight = Color(0xFF7C7A99);

  // Purple gradient: used for the header and the QUESTION side of a card
  static const LinearGradient questionGradient = LinearGradient(
    colors: [purple, darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Teal gradient: used for the ANSWER side of a card
  static const LinearGradient answerGradient = LinearGradient(
    colors: [teal, darkTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
