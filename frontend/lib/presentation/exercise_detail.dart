import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../services/exercise_service.dart';
import '../text_styles.dart';
import 'widgets/navbar.dart';

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C8955),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Кастомная иконка
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: AutoSizeText(
          exercise.title,
          style: TextStyles.title,
          maxLines: 1,
          minFontSize: 19,
          maxFontSize: 24,
        )
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Описание', style: TextStyles.subtitle),
          const SizedBox(height: 8),
          Text(
            exercise.description ?? 'Нет описания.',
            style: TextStyles.body
          ),
          const SizedBox(height: 20),
          Text('Инструкция', style: TextStyles.subtitle),
          const SizedBox(height: 8),
          Text(
            exercise.instructions ?? 'Нет инструкции.',
            style: TextStyles.body,
          ),
          const SizedBox(height: 8),
          if (exercise.mediaUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://res.cloudinary.com/dpq5mqnbe/image/upload/v1746471723/image_14_nzrm7d.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
