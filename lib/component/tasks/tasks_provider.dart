import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:omen/component/tasks/task_model.dart';
import 'package:omen/component/tasks/tasks_sample_data.dart';

const String kTasksBoxName = 'tasks_box';

Future<void> initTasksStorage() async {
  await Hive.initFlutter();
  if (!Hive.isBoxOpen(kTasksBoxName)) {
    await Hive.openBox(kTasksBoxName);
  }
}

class TasksNotifier extends Notifier<List<TaskModel>> {
  Box<dynamic> get _box => Hive.box(kTasksBoxName);

  @override
  List<TaskModel> build() {
    final stored = _box.get('tasks');
    if (stored is List) {
      return stored
          .whereType<Map>()
          .map((entry) => TaskModel.fromMap(entry))
          .toList();
    }

    _save(kSampleTasks);
    return kSampleTasks;
  }

  void addTask({
    required String title,
    String? subtitle,
    required String time,
    String? notes,
    List<String> comments = const [],
    required TaskPriority priority,
    required TaskSection section,
  }) {
    final newTask = TaskModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      subtitle: subtitle?.trim().isEmpty == true ? null : subtitle?.trim(),
      time: formatTaskTime12h(time),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      comments: comments.where((c) => c.trim().isNotEmpty).map((c) => c.trim()).toList(),
      priority: priority,
      section: section,
    );

    state = [...state, newTask];
    _save(state);
  }

  void toggleCompleted(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
    _save(state);
  }

  void toggleStarred(String id) {
    state = [
      for (final task in state)
        if (task.id == id) task.copyWith(isStarred: !task.isStarred) else task,
    ];
    _save(state);
  }

  void _save(List<TaskModel> tasks) {
    _box.put('tasks', tasks.map((task) => task.toMap()).toList());
  }
}

final tasksProvider = NotifierProvider<TasksNotifier, List<TaskModel>>(
  TasksNotifier.new,
);

final taskFilterProvider = StateProvider<TaskFilter>((_) => TaskFilter.all);
final taskSearchQueryProvider = StateProvider<String>((_) => '');
final taskPriorityFilterProvider = StateProvider<TaskPriority?>((_) => null);
final taskSectionFocusProvider = StateProvider<TaskSection?>((_) => null);

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final baseFilter = ref.watch(taskFilterProvider);
  final query = ref.watch(taskSearchQueryProvider).trim().toLowerCase();
  final priority = ref.watch(taskPriorityFilterProvider);
  final section = ref.watch(taskSectionFocusProvider);

  final byStatus = switch (baseFilter) {
    TaskFilter.active => tasks.where((t) => !t.isCompleted).toList(),
    TaskFilter.done => tasks.where((t) => t.isCompleted).toList(),
    TaskFilter.all => tasks,
  };

  return byStatus.where((task) {
    final matchesQuery = query.isEmpty ||
        task.title.toLowerCase().contains(query) ||
        (task.subtitle?.toLowerCase().contains(query) ?? false);
    final matchesPriority = priority == null || task.priority == priority;
    final matchesSection = section == null || task.section == section;
    return matchesQuery && matchesPriority && matchesSection;
  }).toList();
});

final groupedTasksProvider = Provider<Map<TaskSection, List<TaskModel>>>((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  return {
    for (final section in TaskSection.values)
      if (tasks.any((t) => t.section == section))
        section: tasks.where((t) => t.section == section).toList(),
  };
});

final taskProgressProvider = Provider<double>((ref) {
  final tasks = ref.watch(tasksProvider);
  if (tasks.isEmpty) return 0;
  return tasks.where((t) => t.isCompleted).length / tasks.length;
});

enum TaskFilter { all, active, done }
