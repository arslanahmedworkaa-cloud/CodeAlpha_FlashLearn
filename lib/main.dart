import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'home_screen.dart';

void main() {
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.purple,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const HomeScreen(),
    );
  }
}
