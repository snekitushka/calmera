import 'package:calmera/services/user_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class Diary {
  final int? id;
  final DateTime eventDatetime;
  final String emotionalState;
  final String situation;
  final String mood;
  final String thoughts;
  final String bodySensations;


  Diary({
    this.id,
    required this.eventDatetime,
    required this.emotionalState,
    required this.situation,
    required this.mood,
    required this.thoughts,
    required this.bodySensations,
  });

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'],
      eventDatetime: DateTime.parse(json['event_datetime'] ?? '1970-01-01T00:00:00.000Z'),
      emotionalState: json['emotional_state'] ?? 'neutral',
      situation: json['situation'] ?? 'No Situation',
      mood: json['mood'] ?? 'No Mood',
      thoughts: json['thoughts'] ?? 'No Thoughts',
      bodySensations: json['body_sensations'] ?? 'No Body Sensations',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_datetime': eventDatetime.toIso8601String(),
      'emotional_state': emotionalState,
      'situation': situation,
      'mood': mood,
      'thoughts': thoughts,
      'body_sensations': bodySensations,
    };
  }
}

class DiaryService {
  static Future<List<Diary>> fetchDiaryEntries() async {
    try {
      final response = await ApiClient.get('diary');
      final List data = response.data['entries'];
      return data.map((entry) => Diary.fromJson(entry)).toList();
    } catch (e) {
      throw Exception('Ошибка при получении дневника: $e');
    }
  }

  static Future<Diary> createDiaryEntry(Diary newEntry) async {
    try {
      final response = await ApiClient.post(
        'diary',
        newEntry.toJson(),
      );

      return Diary.fromJson(response.data['entry']);
    } catch (e) {
      throw Exception('Ошибка при создании записи: $e');
    }
  }

  static Future<void> deleteDiaryEntry(int id) async {
    try {
      await ApiClient.delete('diary/$id');
    } catch (e) {
      throw Exception('Ошибка при удалении записи: $e');
    }
  }

  static Future<Diary> updateDiaryEntry(int id, Diary updatedEntry) async {
    try {
      final response = await ApiClient.put(
        'diary/$id',
        updatedEntry.toJson(),
      );
      return Diary.fromJson(response.data['entry']);
    } catch (e) {
      throw Exception('Ошибка при обновлении записи: $e');
    }
  }
}







