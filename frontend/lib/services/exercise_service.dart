import 'package:calmera/services/user_service.dart';
import 'package:dio/dio.dart';

class Exercise {
  final String title;
  final String mediaUrl;
  final String category;
  final String description;
  final String instructions;

  Exercise({
    required this.title,
    required this.mediaUrl,
    required this.category,
    required this.description,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
        title: json['title'],
        mediaUrl: json['media_url'] ?? '',
        category: json['type'],
        description: json['description'],
        instructions: json['instructions']
    );
  }
}

class ExerciseService {
  static Future<List<Exercise>> fetchExercises() async {
    try {
      final response = await Dio().get('${urlBase}exercises/?skip=0&limit=50');
      if (response.statusCode == 200) {
        final List data = response.data['exercises'];
        return data.map((e) => Exercise.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }
}
