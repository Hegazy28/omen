// lib/features/tasks/providers/tasks_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/tasks/task_model.dart';
import 'package:omen/component/tasks/tasks_sample_data.dart';
// ── Notifier ──────────────────────────────────────────────────────────────

class TasksNotifier extends Notifier<List<TaskModel>> {
  @override
  List<TaskModel> build() => kSampleTasks;

  void toggleCompleted(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
  }

  void toggleStarred(String id) {
    state = [
      for (final task in state)
        if (task.id == id) task.copyWith(isStarred: !task.isStarred) else task,
    ];
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

/// All tasks — source of truth.
final tasksProvider = NotifierProvider<TasksNotifier, List<TaskModel>>(
  TasksNotifier.new,
);

/// Filtered view used by the widget (driven by [taskFilterProvider]).
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(taskFilterProvider);

  return switch (filter) {
    TaskFilter.active => tasks.where((t) => !t.isCompleted).toList(),
    TaskFilter.done => tasks.where((t) => t.isCompleted).toList(),
    TaskFilter.all => tasks,
  };
});

/// Tasks grouped by section, derived from [filteredTasksProvider].
final groupedTasksProvider = Provider<Map<TaskSection, List<TaskModel>>>((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  return {
    for (final section in TaskSection.values)
      if (tasks.any((t) => t.section == section))
        section: tasks.where((t) => t.section == section).toList(),
  };
});

/// Progress 0.0–1.0 based on all tasks (not filtered).
final taskProgressProvider = Provider<double>((ref) {
  final tasks = ref.watch(tasksProvider);
  if (tasks.isEmpty) return 0;
  return tasks.where((t) => t.isCompleted).length / tasks.length;
});

/// Active filter chip selection.
final taskFilterProvider = StateProvider<TaskFilter>((_) => TaskFilter.all);

// ── Enum ──────────────────────────────────────────────────────────────────

enum TaskFilter { all, active, done }
