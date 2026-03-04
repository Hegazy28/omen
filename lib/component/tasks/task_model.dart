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

String formatTaskTime12h(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return value;

  final twelveHourPattern = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$');
  final match12 = twelveHourPattern.firstMatch(value);
  if (match12 != null) {
    final hour = int.tryParse(match12.group(1)!);
    final minute = int.tryParse(match12.group(2)!);
    final period = match12.group(3)!.toUpperCase();
    if (hour != null &&
        minute != null &&
        hour >= 1 &&
        hour <= 12 &&
        minute >= 0 &&
        minute <= 59) {
      return '${hour.toString()}:${minute.toString().padLeft(2, '0')} $period';
    }
  }

  final twentyFourPattern = RegExp(r'^(\d{1,2}):(\d{2})$');
  final match24 = twentyFourPattern.firstMatch(value);
  if (match24 != null) {
    final hour24 = int.tryParse(match24.group(1)!);
    final minute = int.tryParse(match24.group(2)!);
    if (hour24 != null &&
        minute != null &&
        hour24 >= 0 &&
        hour24 <= 23 &&
        minute >= 0 &&
        minute <= 59) {
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
      return '${hour12.toString()}:${minute.toString().padLeft(2, '0')} $period';
    }
  }

  return value;
}

@immutable
class TaskModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? notes;
  final List<String> comments;
  final String time;
  final TaskPriority priority;
  final TaskSection section;
  final bool isCompleted;
  final bool isStarred;

  const TaskModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.notes,
    this.comments = const [],
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
      notes: map['notes'] as String?,
      comments: (map['comments'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      time: formatTaskTime12h(map['time'] as String? ?? ''),
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
        'notes': notes,
        'comments': comments,
        'time': time,
        'priority': priority.name,
        'section': section.name,
        'isCompleted': isCompleted,
        'isStarred': isStarred,
      };

  TaskModel copyWith({
    bool? isCompleted,
    bool? isStarred,
    String? notes,
    List<String>? comments,
  }) {
    return TaskModel(
      id: id,
      title: title,
      subtitle: subtitle,
      notes: notes ?? this.notes,
      comments: comments ?? this.comments,
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
