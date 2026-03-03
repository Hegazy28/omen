// lib/features/tasks/models/task_model.dart

import 'package:flutter/foundation.dart';

enum TaskPriority { high, medium, low }

enum TaskSection { morning, afternoon, evening }

@immutable
class TaskModel {
  final String id;
  final String title;
  final String? subtitle;
  final String time;
  final TaskPriority priority;
  final TaskSection section;
  final bool isCompleted;
  final bool isStarred;

  const TaskModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.time,
    required this.priority,
    required this.section,
    this.isCompleted = false,
    this.isStarred = false,
  });

  TaskModel copyWith({
    bool? isCompleted,
    bool? isStarred,
  }) {
    return TaskModel(
      id: id,
      title: title,
      subtitle: subtitle,
      time: time,
      priority: priority,
      section: section,
      isCompleted: isCompleted ?? this.isCompleted,
      isStarred: isStarred ?? this.isStarred,
    );
  }

  @override
  bool operator ==(Object other) => other is TaskModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
