import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/tasks/task_model.dart';
import 'package:omen/component/tasks/tasks_provider.dart';
import 'tasks_theme.dart';
import 'tasks_progress_bar.dart';
import 'tasks_filter_bar.dart';
import 'period_column.dart';

class TasksWidget extends ConsumerWidget {
  const TasksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedTasksProvider);
    final progress = ref.watch(taskProgressProvider);
    final allTasks = ref.watch(tasksProvider);
    final completed = allTasks.where((t) => t.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopBar(
          completedCount: completed,
          totalCount: allTasks.length,
        ),
        const SizedBox(height: 16),
        TasksProgressBar(
          progress: progress,
          completed: completed,
          total: allTasks.length,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _ColumnsRow(grouped: grouped),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const _TopBar({
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('My Tasks', style: TaskTextStyles.heading(22)),
        const SizedBox(width: 12),
        Text(
          '$completedCount / $totalCount',
          style: TaskTextStyles.mono(13, color: TaskColors.text3),
        ),
        const Spacer(),
        const TasksFilterBar(),
        const SizedBox(width: 12),
        const _AddButton(),
      ],
    );
  }
}

class _AddButton extends ConsumerWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        await showDialog<void>(
          context: context,
          builder: (_) => const _AddTaskDialog(),
        );
      },
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [TaskColors.primaryGlow, TaskColors.primary],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: TaskColors.primary.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 17, color: TaskColors.skyDeep),
            const SizedBox(width: 5),
            Text(
              'Add Task',
              style: TaskTextStyles.body(13).copyWith(
                fontWeight: FontWeight.w700,
                color: TaskColors.skyDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTaskDialog extends ConsumerStatefulWidget {
  const _AddTaskDialog();

  @override
  ConsumerState<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<_AddTaskDialog> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _timeController = TextEditingController(text: '09:00');
  TaskPriority _priority = TaskPriority.medium;
  TaskSection _section = TaskSection.morning;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _subtitleController,
                decoration: const InputDecoration(labelText: 'Subtitle (optional)'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (HH:mm)'),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TaskPriority.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TaskSection>(
                value: _section,
                decoration: const InputDecoration(labelText: 'Section'),
                items: TaskSection.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _section = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Title is required')),
              );
              return;
            }

            ref.read(tasksProvider.notifier).addTask(
                  title: title,
                  subtitle: _subtitleController.text.trim(),
                  time: _timeController.text.trim().isEmpty
                      ? '09:00'
                      : _timeController.text.trim(),
                  priority: _priority,
                  section: _section,
                );
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _ColumnsRow extends StatelessWidget {
  final Map<TaskSection, List<TaskModel>> grouped;

  const _ColumnsRow({required this.grouped});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: TaskSection.values.map((section) {
        final tasks = grouped[section] ?? [];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: section != TaskSection.values.last ? 14 : 0,
            ),
            child: PeriodColumn(
              section: section,
              tasks: tasks,
            ),
          ),
        );
      }).toList(),
    );
  }
}
