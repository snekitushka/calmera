import 'package:calmera/text_styles.dart';
import 'package:calmera/presentation/exercise_detail.dart';
import 'package:calmera/presentation/widgets/exercise/exercise_card.dart';
import 'package:calmera/presentation/widgets/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/exercise_service.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  late Future<List<Exercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = ExerciseService.fetchExercises();
  }

  Map<String, List<Exercise>> groupByCategory(List<Exercise> list) {
    final Map<String, List<Exercise>> grouped = {};
    for (var item in list) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2C8955),
          scrolledUnderElevation: 0,
        title: Text('Техники и упражнения', style: TextStyles.title,)),
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки'));
          }

          final grouped = groupByCategory(snapshot.data!);

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
                    child: Text(
                      categoryTitle(entry.key),
                      style: TextStyles.subtitle),
                    ),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      padding: const EdgeInsets.only(right: 8, left: 16),
                      itemBuilder: (context, index) {
                        return ExerciseCard(exercise: entry.value[index]);
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  String categoryTitle(String key) {
    switch (key) {
      case 'cbt':
        return 'Когнитивные искажения';
      case 'breathing':
        return 'Тревога и беспокойство';
      case 'relaxation':
        return 'Мотивация и цели';
      case 'meditation':
        return 'Самооценка и уверенность в себе';
      default:
        return key;
    }
  }
}


