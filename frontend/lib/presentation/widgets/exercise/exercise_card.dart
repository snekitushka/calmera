import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../services/exercise_service.dart';
import '../../exercise_detail.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailPage(exercise: exercise),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
          image: exercise.mediaUrl.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(exercise.mediaUrl),
            fit: BoxFit.cover,
            colorFilter:
            ColorFilter.mode(Colors.black26, BlendMode.darken),
          )
              : null,
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              exercise.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}