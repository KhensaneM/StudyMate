import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_task.dart';

class StudyStorage {
  static const String _storageKey = 'studymate_tasks';

  /// Saves all assignments to local device storage.
  static Future<void> saveTasks(List<StudyTask> tasks) async {
    final preferences = await SharedPreferences.getInstance();

    final taskData = tasks.map((task) {
      return <String, dynamic>{
        'id': task.id,
        'title': task.title,
        'subject': task.subject,
        'deadline': task.deadline.toIso8601String(),
        'priority': task.priority.name,
        'isCompleted': task.isCompleted,
      };
    }).toList();

    final encodedTasks = jsonEncode(taskData);

    final saved = await preferences.setString(_storageKey, encodedTasks);

    if (!saved) {
      throw StateError('Could not save StudyMate assignments.');
    }
  }

  /// Loads saved assignments from local device storage.
  static Future<List<StudyTask>> loadTasks() async {
    final preferences = await SharedPreferences.getInstance();

    final savedData = preferences.getString(_storageKey);

    if (savedData == null || savedData.isEmpty) {
      return <StudyTask>[];
    }

    final decodedData = jsonDecode(savedData);

    if (decodedData is! List) {
      throw const FormatException(
        'Saved StudyMate assignments have an invalid format.',
      );
    }

    return decodedData.map<StudyTask>((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('A saved StudyMate assignment is invalid.');
      }

      final priorityName = item['priority'] as String?;

      final priority = TaskPriority.values.firstWhere(
        (value) => value.name == priorityName,
        orElse: () => TaskPriority.medium,
      );

      return StudyTask(
        id: item['id'] as String,
        title: item['title'] as String,
        subject: item['subject'] as String,
        deadline: DateTime.parse(item['deadline'] as String),
        priority: priority,
        isCompleted: item['isCompleted'] as bool? ?? false,
      );
    }).toList();
  }

  /// Removes all saved assignments.
  static Future<void> clearTasks() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
