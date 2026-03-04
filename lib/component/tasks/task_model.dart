import 'package:flutter/foundation.dart';

enum TaskPriority { high, medium, low }

enum TaskSection { morning, afternoon, evening }

TaskPriority taskPriorityFromString(String value) {
  return TaskPriority.values.firstWhere(
    (priority) => priority.name == value,
    orElse: () => TaskPriority.medium,
  );
}

TaskSection taskSectionFromString(String value) {
  return TaskSection.values.firstWhere(
    (section) => section.name == value,
    orElse: () => TaskSection.morning,
  );
}

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

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      time: map['time'] as String,
      priority: taskPriorityFromString(map['priority'] as String? ?? ''),
      section: taskSectionFromString(map['section'] as String? ?? ''),
      isCompleted: map['isCompleted'] as bool? ?? false,
      isStarred: map['isStarred'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'time': time,
        'priority': priority.name,
        'section': section.name,
        'isCompleted': isCompleted,
        'isStarred': isStarred,
      };

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
